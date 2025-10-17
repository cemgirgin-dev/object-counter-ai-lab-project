"""Application-wide configuration utilities."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import List


@dataclass(frozen=True)
class Settings:
    """Centralised settings with directory helpers."""

    backend_root: Path = field(default_factory=lambda: Path(__file__).resolve().parents[2])

    @property
    def project_root(self) -> Path:
        return self.backend_root.parent

    @property
    def data_dir(self) -> Path:
        return self.backend_root / "data"

    @property
    def database_path(self) -> Path:
        return self.data_dir / "db" / "object_counter.db"

    @property
    def segmented_images_dir(self) -> Path:
        return self.data_dir / "segmented_images"

    @property
    def generated_images_dir(self) -> Path:
        return self.data_dir / "generated_images"

    @property
    def uploads_dir(self) -> Path:
        return self.data_dir / "uploads"

    @property
    def few_shot_models_dir(self) -> Path:
        return self.data_dir / "few_shot" / "models"

    @property
    def few_shot_training_dir(self) -> Path:
        return self.data_dir / "few_shot" / "training_data"

    @property
    def weights_dir(self) -> Path:
        return self.data_dir / "weights"

    @property
    def static_root(self) -> Path:
        return self.project_root

    @property
    def allowed_origins(self) -> List[str]:
        return ["*"]

    def ensure_directories(self) -> None:
        """Create data directories if they do not exist."""
        for directory in [
            self.data_dir,
            self.database_path.parent,
            self.segmented_images_dir,
            self.generated_images_dir,
            self.uploads_dir,
            self.few_shot_models_dir,
            self.few_shot_training_dir,
            self.weights_dir,
        ]:
            directory.mkdir(parents=True, exist_ok=True)


settings = Settings()
settings.ensure_directories()

__all__ = ["settings"]
