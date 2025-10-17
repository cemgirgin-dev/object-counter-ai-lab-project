"""SQLite persistence layer for object counting results."""

from __future__ import annotations

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from app.core.config import settings


class DatabaseManager:
    """Simple wrapper around SQLite for storing detection results."""

    def __init__(self, db_path: Optional[Path] = None) -> None:
        self.db_path = Path(db_path or settings.database_path)
        self.init_database()

    def init_database(self) -> None:
        """Initialize the database with required tables."""
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS count_results (
                    result_id TEXT PRIMARY KEY,
                    image_path TEXT NOT NULL,
                    object_type TEXT NOT NULL,
                    count INTEGER NOT NULL,
                    corrected_count INTEGER,
                    confidence REAL NOT NULL,
                    timestamp DATETIME NOT NULL,
                    segmented_image_path TEXT
                )
                """
            )

            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS corrections (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    result_id TEXT NOT NULL,
                    corrected_count INTEGER NOT NULL,
                    timestamp DATETIME NOT NULL,
                    FOREIGN KEY (result_id) REFERENCES count_results (result_id)
                )
                """
            )
            conn.commit()

    def store_count_result(
        self,
        result_id: str,
        image_path: str,
        object_type: str,
        count: int,
        confidence: float,
        timestamp: datetime,
        segmented_image_path: Optional[str] = None,
    ) -> None:
        """Store a count result in the database."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO count_results
                (result_id, image_path, object_type, count, confidence, timestamp, segmented_image_path)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    result_id,
                    image_path,
                    object_type,
                    count,
                    confidence,
                    timestamp.isoformat(),
                    segmented_image_path,
                ),
            )
            conn.commit()

    def store_correction(self, result_id: str, corrected_count: int, timestamp: datetime) -> None:
        """Store a correction for a count result."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO corrections (result_id, corrected_count, timestamp)
                VALUES (?, ?, ?)
                """,
                (result_id, corrected_count, timestamp.isoformat()),
            )
            cursor.execute(
                """
                UPDATE count_results
                SET corrected_count = ?
                WHERE result_id = ?
                """,
                (corrected_count, result_id),
            )
            conn.commit()

    def get_result(self, result_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific result by ID."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT result_id, image_path, object_type, count, corrected_count,
                       confidence, timestamp, segmented_image_path
                FROM count_results
                WHERE result_id = ?
                """,
                (result_id,),
            )

            row = cursor.fetchone()
            if row:
                return {
                    "result_id": row[0],
                    "image_path": row[1],
                    "object_type": row[2],
                    "count": row[3],
                    "corrected_count": row[4],
                    "confidence": row[5],
                    "timestamp": row[6],
                    "segmented_image_path": row[7],
                }
            return None

    def get_all_results(self, limit: int = 10, offset: int = 0) -> List[Dict[str, Any]]:
        """Get all results with pagination."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT result_id, image_path, object_type, count, corrected_count,
                       confidence, timestamp, segmented_image_path
                FROM count_results
                ORDER BY timestamp DESC
                LIMIT ? OFFSET ?
                """,
                (limit, offset),
            )
            rows = cursor.fetchall()
            return [
                {
                    "result_id": row[0],
                    "image_path": row[1],
                    "object_type": row[2],
                    "count": row[3],
                    "corrected_count": row[4],
                    "confidence": row[5],
                    "timestamp": row[6],
                    "segmented_image_path": row[7],
                }
                for row in rows
            ]

    def get_statistics(self) -> Dict[str, Any]:
        """Get statistics about the database."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM count_results")
            total_results = cursor.fetchone()[0]

            cursor.execute(
                """
                SELECT object_type, COUNT(*)
                FROM count_results
                GROUP BY object_type
                """
            )
            by_object_type = dict(cursor.fetchall())

            cursor.execute("SELECT AVG(confidence) FROM count_results")
            avg_confidence = cursor.fetchone()[0] or 0

            cursor.execute("SELECT COUNT(*) FROM corrections")
            total_corrections = cursor.fetchone()[0]

            return {
                "total_results": total_results,
                "by_object_type": by_object_type,
                "average_confidence": round(avg_confidence, 3),
                "total_corrections": total_corrections,
            }


__all__ = ["DatabaseManager"]
