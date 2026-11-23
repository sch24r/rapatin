```mermaid
flowchart TB
    subgraph MobileUsers["Pengguna Aplikasi Mobile (1 Aplikasi, 2 POV)"]
        P["Penyewa<br/>(Mahasiswa / PIC Panitia)"]
        M["Mitra<br/>(Pengelola Kafe / Resto)"]
    end

    subgraph Mobile["Aplikasi Mobile Rapatin (Flutter - Android)"]
        UI["Presentation Layer<br/>(POV Penyewa & POV Mitra)"]
        SM["Application & State Layer<br/>(State Management, Role Routing, Pengingat H-1)"]
        REPO["Data Layer<br/>(Repository & supabase_flutter SDK)"]
        UI <--> SM
        SM <--> REPO
    end

    subgraph AdminClient["Aplikasi Admin Rapatin (Web / App Terpisah)"]
        ADM["Admin Rapatin"]
        ADM_UI["Admin Panel UI<br/>(Verifikasi Bayar, Refund, Pencairan Mitra)"]
        ADM_SDK["Client SDK<br/>(supabase-js / supabase_flutter)"]
        ADM --> ADM_UI
        ADM_UI <--> ADM_SDK
    end

    subgraph Supabase["Supabase Cloud (Backend-as-a-Service)"]
        AUTH["Supabase Auth<br/>(JWT & 3 Role: Penyewa, Mitra, Admin)"]
        API["PostgREST API<br/>(CRUD Data API)"]
        RT["Supabase Realtime<br/>(Sinkronisasi Slot & Status)"]
        DB[("PostgreSQL + RLS<br/>(Tempat, Ruang, Menu, Slot,<br/>Booking, Pembayaran, Pencairan)")]
        ST[("Supabase Storage<br/>(Foto Tempat, QRIS Statis,<br/>Bukti Pembayaran)")]

        AUTH --> DB
        API <--> DB
        RT <--> DB
    end

    subgraph External["Pembayaran & Transfer Manual (Di Luar Sistem)"]
        PAY["Saluran Pembayaran Eksternal<br/>(QRIS Statis Rapatin & Transfer Bank/E-Wallet)"]
    end

    P --> UI
    M --> UI

    REPO -- "HTTPS (Auth, REST, Storage)" --> AUTH
    REPO -- "HTTPS (REST + JWT)" --> API
    REPO -- "WebSocket (WSS)" --> RT
    REPO -- "HTTPS (Unggah / Unduh)" --> ST

    ADM_SDK -- "HTTPS (Auth Admin + JWT)" --> AUTH
    ADM_SDK -- "HTTPS (Verifikasi & Update Status)" --> API
    ADM_SDK -- "HTTPS (Tinjau Bukti Bayar)" --> ST

    P -. "Bayar Penuh via QRIS Statis" .-> PAY
    ADM -. "Cek Mutasi, Refund & Transfer Pencairan" .-> PAY
    PAY -. "Dana Diteruskan (H+2x24 Jam)" .-> M
    ```