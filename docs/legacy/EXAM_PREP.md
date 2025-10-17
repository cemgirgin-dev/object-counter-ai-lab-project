# Group 6 Oral Exam Prep Guide

## 1. Sistem Mimarisi Genel Bakış
- **Backend**: FastAPI uygulaması tüm çekirdek bileşenleri (YOLO pipeline, güvenlik pipeline, metrik toplayıcı, veritabanı) başlatıp CORS ve statik dosya yapılandırmalarını kurar (backend/main.py:13, backend/main.py:26, backend/main.py:35, backend/main.py:57).
- **Frontend**: Flutter web uygulaması dört ana sekme (Basic, Advanced, Generator, Monitor) ile çalışır ve backend ile HTTP üzerinden konuşur (frontend/lib/main.dart:102).
- **Depolama**: Sayım sonuçları ve düzeltmeler SQLite veritabanında tutulur (backend/database.py:19).
- **Observability**: Prometheus backend’in `/metrics` ucunu scrape eder; Grafana, provision edilmiş dashboardlarla metrikleri görselleştirir (monitoring/prometheus.yml:15, monitoring/grafana/provisioning/dashboards/dashboard.yml:4).

## 2. İstek Pipeline’ı (Basic Mode)
1. **Dosya ve Form Doğrulama** – API önce yüklenen dosyanın görsel tipinde olduğunu ve nesne tipinin izin verilen listede bulunduğunu kontrol eder (backend/main.py:119, backend/main.py:127).
2. **Görüntü Açma** – Pillow ile görüntü açılır; başarısız olursa 400 hatası döner (backend/main.py:145).
3. **Güvenlik Kontrolü** – `safety_pipeline.check_safety` çağrılır. Riskli bulunursa 403 yanıtı döner ve metrikler güncellenir (backend/main.py:172, backend/metrics.py:194).
4. **YOLO Sayımı** – `yolo_pipeline.process_image` hedef nesneleri sayar, süreyi ve güven skorlarını hesaplar (backend/main.py:200, backend/yolo_ml_pipeline.py:218).
5. **Metrik Kaydı** – Model süresi, güven skoru, görüntü çözünürlüğü, nesne sayıları Prometheus histogramlarına yazılır (backend/metrics.py:123, backend/metrics.py:127, backend/metrics.py:140).
6. **Veritabanı** – Rastgele UUID ile sonuç kaydı `count_results` tablosuna eklenir (backend/main.py:212).
7. **Yanıt** – `CountResponse` modeliyle kullanıcıya sonuç JSON’u döner (backend/main.py:230).

## 3. YOLOv8 Sayım Pipeline’ı
- **Cihaz Seçimi** – Metal (MPS), CUDA veya CPU otomatik belirlenir ve model sadece ilk çağrıda yüklenir (backend/yolo_ml_pipeline.py:24, backend/yolo_ml_pipeline.py:33).
- **Ön İşleme** – Görsel RGB’ye çevrilir, 640×640’e yeniden örneklenir, NumPy dizisine dönüştürülür (backend/yolo_ml_pipeline.py:150, backend/yolo_ml_pipeline.py:158, backend/yolo_ml_pipeline.py:161).
- **Eşikler ve Esneklik** – Hedef sınıf için 0.15 güven eşiği kullanılır; hayvan sınıfları arasında esnek eşleşme yapılır (backend/yolo_ml_pipeline.py:187, backend/yolo_ml_pipeline.py:193).
- **Çıktı** – Ortalama güven skoru, toplam tespit sayısı, hedef sayım ve isteğe bağlı segmentasyon görseli döndürülür (backend/yolo_ml_pipeline.py:205, backend/yolo_ml_pipeline.py:211, backend/yolo_ml_pipeline.py:218).
- **Hafıza Temizliği** – Her çağrı sonrası GPU/MPS önbelleği boşaltılır (backend/yolo_ml_pipeline.py:43).

## 4. Gelişmiş Model Pipeline (SAM + ResNet-50 + DistilBERT)
- **Çok Aşamalı Tasarım** – `ObjectCounter` sınıfı SAM ile segment üretip ResNet-50 ve DistilBERT ile etiket rafine ederek son sayımı yapar (../ai-engineering-lab-project/model_pipeline.py:19).
- **SAM Başlatma** – `sam_vit_b_01ec64.pth` kontrol noktası indirilip `SamAutomaticMaskGenerator` yüksek `pred_iou_thresh` ve `stability_score_thresh` ile maskeleri kaliteye göre üretir (../ai-engineering-lab-project/model_pipeline.py:57).
- **ResNet-50 Sınıflandırması** – `AutoImageProcessor` ile 256 piksele yeniden boyutlanan segmentler karışık duyarlıklı (AMP) olarak toplu şekilde sınıflandırılır, en iyi üç tahmin ağırlıklı oylamayla birleşir (../ai-engineering-lab-project/model_pipeline.py:103) (../ai-engineering-lab-project/model_pipeline.py:417) (../ai-engineering-lab-project/model_pipeline.py:428) (../ai-engineering-lab-project/model_pipeline.py:458).
- **DistilBERT Etiket Rafinesi** – Zero-shot pipeline, ResNet çıktısını bağlamsal cümleyle etiket adaylarına karşı test eder; eşik altında kaldığında hiyerarşik eşanlamlılarla yedeklenir (../ai-engineering-lab-project/model_pipeline.py:126) (../ai-engineering-lab-project/model_pipeline.py:487).
- **Segment İşleme** – SAM maskeleri çok ölçekli üretilip morfolojik filtrelerle temizlenir, IoU tabanlı NMS ile yinelenenler atılır, panoptik harita oluşturulur (../ai-engineering-lab-project/model_pipeline.py:200) (../ai-engineering-lab-project/model_pipeline.py:276) (../ai-engineering-lab-project/model_pipeline.py:333) (../ai-engineering-lab-project/model_pipeline.py:363).
- **Sayım Mantığı** – ResNet ve DistilBERT aynı etiket üzerinde anlaşırsa güven artırılır; maskelerin stabilite ve kenar yoğunluğu skorları ile ağırlıklandırılmış ortalama güven hesaplanır (../ai-engineering-lab-project/model_pipeline.py:534) (../ai-engineering-lab-project/model_pipeline.py:555) (../ai-engineering-lab-project/model_pipeline.py:561).
- **Ön/Art İşleme** – Görseller kontrast, keskinlik ve dw-blur ile geliştirilir; sonuçlar önbelleğe alınarak tekrar eden çağrılarda hız kazanılır (../ai-engineering-lab-project/model_pipeline.py:258) (../ai-engineering-lab-project/model_pipeline.py:244).

## 5. Güvenlik (Safety) Pipeline’ı
- **CNN Mimarisi** – Residual bloklara sahip iki sınıflı (sivil/askerî) CNN tanımlıdır (backend/safety_pipeline.py:23, backend/safety_pipeline.py:35).
- **Heuristikler** – Gerçek ağırlıklar olmadığı için dosya adı, parlaklık, boyut ve en-boy oranı gibi kurallarla “askerî” içerik simüle edilir (backend/safety_pipeline.py:145).
- **Metin Analizi** – Kullanıcının seçtiği nesne tipinde `tank`, `war` gibi anahtar kelimeleri arar ve risk seviyesini `high` olarak işaretler (backend/safety_pipeline.py:239).
- **Karar Mantığı** – Nesne tipi yasaklısa veya tespit güveni ≥0.8 ise istek engellenir; aksi halde izin verilir (backend/safety_pipeline.py:267, backend/safety_pipeline.py:273).
- **İstatistikler** – Her çağrıda toplam istek, bloklanan istek ve blok nedenleri sayaçları güncellenir; `/api/safety-stats` üzerinden izlenir (backend/safety_pipeline.py:344, backend/main.py:83).

## 6. Few-Shot Öğrenme Mekanizması
- **Başlangıç** – `FewShotLearningPipeline` taban modeli (`yolov8n.pt`) yükler ve eğitim/model klasörlerini hazırlar (backend/few_shot_learning.py:20, backend/few_shot_learning.py:28).
- **Veri Kaydı** – Kullanıcının yüklediği en az üç görsel `few_shot_training_data/<nesne>` klasörüne kaydedilir (backend/few_shot_learning.py:67).
- **Etiketleme** – Her görsel için tüm çerçeveyi kapsayan basit YOLO formatı etiket dosyası üretilir (backend/few_shot_learning.py:84).
- **Model Dosyası** – Gerçek fine-tuning yapılmıyor; taban model kopyalanarak yer tutucu `.pt` dosyası oluşturuluyor (backend/few_shot_learning.py:157).
- **Algılama** – Sayım çağrılarında temel YOLO pipeline’ı tekrar kullanılır, eğitim görseli sayısına bağlı süre cezası eklenir ve sonuç meta verisiyle döner (backend/few_shot_learning.py:188, backend/few_shot_learning.py:205).
- **Durum Yönetimi** – Öğrenilen sınıflar `few_shot_models/learned_classes.json` dosyasında saklanır ve API ile listelenir/silinir (backend/few_shot_learning.py:93, backend/few_shot_learning.py:231).

## 7. Görüntü Üretim (Image Generator) Mekanizması
- **Yer Tutucu Üretim** – Şu anda gerçek AI servisine bağlanmıyor; prompt’a göre basit şekiller çizen yerel bir resim oluşturucu kullanılıyor (image_generator.py:18, image_generator.py:73).
- **Augmentasyonlar** – Bulanıklık (Gaussian), rotasyon ve gürültü gibi parametreler uygulanabilir (image_generator.py:115, image_generator.py:139, image_generator.py:157).
- **Kaydetme** – Üretilen görseller proje içindeki `generated_images` klasörüne kaydedilip backend tarafından URL’ye çevrilir (backend/main.py:399).

## 8. Frontend İş Akışları
- **Basic Mode** – Nesne listesini `/object-types` üzerinden çeker, görseli seçer ve sayım isteği gönderir; başarıda sonuç kartları, blokta güvenlik diyaloğu gösterir (frontend/lib/main.dart:420, frontend/lib/main.dart:455, frontend/lib/main.dart:600).
- **Advanced Mode** – Yeni sınıf öğrenmek için form ve dosya yükleme, öğrenilen sınıfları listeleme ve test etme akışı sunar (frontend/lib/advanced_mode_screen.dart:48, frontend/lib/advanced_mode_screen.dart:120, frontend/lib/advanced_mode_screen.dart:172).
- **Image Generator** – Form parametrelerini backend’e gönderip dönen URL’leri grid halinde gösterir (frontend/lib/main.dart:1646, frontend/lib/main.dart:1685).
- **Monitor** – `/metrics` ucunu ping’leyerek bağlantı durumunu gösterir ve Prometheus/Grafana linklerini açar (frontend/lib/main.dart:2058, frontend/lib/main.dart:2184).
- **UX Detayı** – Güvenlik blokları Snackbar ve modal ile bildiriliyor; sınavda güvenlik-UX entegrasyonu sorulursa bu akışı vurgulayın (frontend/lib/main.dart:494, frontend/lib/main.dart:600).

## 9. Metrikler ve Formüller
### 8.1 Prometheus Sayaç ve Histogramları
- HTTP istek sayısı/süresi: `http_requests_total`, `http_request_duration_seconds` (backend/metrics.py:10, backend/metrics.py:16).
- Model performansı: `model_inference_duration_seconds`, `model_confidence_score` (backend/metrics.py:23, backend/metrics.py:29).
- Görüntü özellikleri: `image_resolution_pixels`, `objects_detected_count`, `segments_found_count`, `object_types_detected_count` (backend/metrics.py:55, backend/metrics.py:61, backend/metrics.py:67, backend/metrics.py:73).
- Güvenlik: `safety_blocks_total`, `safety_detection_confidence` (backend/metrics.py:99, backend/metrics.py:105).
- Yanıt süresi özeti ve aktif istek sayacı: `api_response_time_seconds`, `active_requests` (backend/metrics.py:92, backend/metrics.py:80).

### 8.2 Doğruluk (Accuracy), Precision ve Recall Hesaplama
- Kullanıcı düzeltmeleri geldiğinde sistem tahmin ve gerçek değerleri dizi halinde saklıyor (backend/metrics.py:147).
- `_update_accuracy_metrics` fonksiyonu doğru tahmin sayısını bulup Accuracy = (doğru tahmin / toplam düzeltme) × 100 olarak hesaplıyor; Precision ve Recall da ayni değere ayarlanıyor (backend/metrics.py:169, backend/metrics.py:175, backend/metrics.py:179).

**Örnek Senaryo**  
1. Görsel 1: Model 2 kedi saydı, kullanıcı düzeltme girmedi (gerçek 2). Komut `record_correction` ancak kullanıcı değer girerse 2 olacaktır. Varsayalım gerçeği 2 olarak onayladı – tahmin = 2, düzeltme = 2 → doğru.
2. Görsel 2: Model 4 kedi saydı, kullanıcı gerçeğin 3 olduğunu belirtti → tahmin = 4, düzeltme = 3 → yanlış.

Toplam iki örnekten yalnızca biri doğru olduğu için:  
- **Accuracy** = 1 / 2 = 0.5 → %50.  
- **Precision** = %50 (kodda accuracy ile aynı değer atanıyor).  
- **Recall** = %50 (aynı mekanizma).

Bu değerler Prometheus üzerinde `model_accuracy`, `model_precision`, `model_recall` gauge’larına set edilir (backend/metrics.py:36, backend/metrics.py:42, backend/metrics.py:48).

## 10. Monitoring Stack
- **Prometheus** – Backend’in `host.docker.internal:8000/metrics` ucunu 5 saniyede bir scrape eder; ihtiyaç halinde diğer servisler eklenebilir (monitoring/prometheus.yml:15).
- **Grafana** – Prometheus veri kaynağı Docker içindeki `http://prometheus:9090` olarak tanımlıdır (monitoring/grafana/provisioning/datasources/prometheus.yml:4).
- **Dashboard v2** – İstek hızı, yanıt süresi, güvenlik blokları, model doğruluğu ve güven dağılımını içeren 16 panelden oluşur (monitoring/grafana/provisioning/dashboards/ai_counter_dashboard_v2.json:4, monitoring/grafana/provisioning/dashboards/ai_counter_dashboard_v2.json:145).
- **Metrik Üretimi** – `python generate_test_metrics.py` komutu metrikleri doldurmak için sağlık ve liste uçlarını periyodik çağırır (generate_test_metrics.py:23).

## 11. Veritabanı ve API Uçları
- `count_results` tablosu: result_id, image_path, object_type, count, confidence ve opsiyonel segmented görsel yolunu saklar (backend/database.py:20).
- `corrections` tablosu: kullanıcı düzeltmelerini result_id ile ilişkilendirerek kaydeder (backend/database.py:34).
- `/api/correct` kaydı güncelleyip metrikleri tetikler, `/api/results` çektirir, `/api/results/{id}` tek kaydı döner (backend/main.py:247, backend/main.py:278, backend/main.py:291).
- `/api/learn-object`, `/api/learned-objects`, `/api/count-learned` few-shot akışını yönetir (backend/main.py:303, backend/main.py:336, backend/main.py:373).
- `/api/generate-images` yerel görüntü üreticisini parametrelerle çağırır (backend/main.py:373).

## 12. Sınavda Çıkabilecek Detay Soruları İçin İpuçları
- **“Güvenlik modeli gerçek bir CNN mi?”** → CNN tanımı mevcut fakat eğitim ağırlıkları sağlanmıyor; beslendiği heuristikleri ve fail-safe davranışını anlatın (backend/safety_pipeline.py:145).
- **“Few-shot gerçekten öğreniyor mu?”** → Şu an sadece taban ağı kopyalayan bir yer tutucu; bu sınırlılığı belirtip olası iyileştirmeleri konuşun (backend/few_shot_learning.py:157).
- **“Metrikler nasıl test edilir?”** → `generate_test_metrics.py` ve Prometheus/Grafana provisioning’inden bahsedin (generate_test_metrics.py:23, monitoring/grafana/provisioning/dashboards/ai_counter_dashboard_v2.json:145).
- **“Kullanıcı arayüzü güvenlik uyarılarını nasıl sunuyor?”** → Snackbar + modal dizaynını gösteren kodu işaret edin (frontend/lib/main.dart:494, frontend/lib/main.dart:600).
- **“Accuracy neden Precision/Recall ile aynı?”** → Kodda sayaçlar eşitlenmiş çünkü gerçek sınıflandırma değil sayım hatalarının izlenmesi hedeflenmiş (backend/metrics.py:175, backend/metrics.py:179).
- **“Devreye alma/çekirdek başlatma sırası nedir?”** → `start_backend.sh`, `start_frontend.sh`, `start_monitoring.sh` akışını ve servis URL’lerini belirtin (start_backend.sh:5, start_monitoring.sh:31).
- **“Model kartı neleri içeriyor?”** → Amacı, veri seti inançları, etik riskler ve izleme metriklerini `MODEL_CARD.md`’den özetleyin (MODEL_CARD.md:15, MODEL_CARD.md:147).

## 13. Hazırlık Kontrol Listesi
- `./start_system.sh` çalıştırıp dört frontend sekmesinin tamamında demo senaryosu oynatın.
- Grafana’da “AI Object Counter Dashboard v2.0” panelini açıp her panelin hangi Prometheus ifadesini kullandığını açıklamayı prova edin.
- Few-shot akışında yeni bir sahte sınıf (ör. “mug”) öğrenip `/api/count-learned` ile test edin.
- Güvenlik modülünü tetiklemek için isiminde “tank” geçen bir dosya yükleyip 403 yanıtındaki `reason`, `confidence`, `processing_time` alanlarını yorumlamayı hazırlayın.
- Accuracy/Precision/Recall örneğini sözlüde hızlı hesaplayabilmek için senaryoyu ezberleyin.
