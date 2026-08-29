# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**AMHIntern** is a production MLM (Multi-Level Marketing) / network management system with e-commerce and tour booking. It is a traditional server-rendered PHP application deployed on Apache + MySQL.

Live environments:
- Production: `https://intern.amhtechno.com` → database `amhtechn_intern`
- Trial: `https://trial.amhtechno.com` → database `amhtechn_intrial`
- Training: `https://training.amhtechno.com` → database `amhtechn_intrain`

## Running the Application

There is no build step. Deploy files directly to an Apache server with PHP and MySQL.

```bash
# Import initial schema (choose environment):
mysql -u <user> -p amhtechn_intern < Bahan/SQLIntern.sql
mysql -u <user> -p amhtechn_intrial < Bahan/SQLTrial.sql
mysql -u <user> -p amhtechn_intrain < Bahan/SQLTrain.sql
```

Database credentials and environment routing are in `server/config.php`. The active environment is selected by matching `$_SERVER['SERVER_NAME']` against known hostnames.

Database backups are stored in `backupdb/*.sql` and `manager/backup_data.sql`.

## Architecture

### Entry Point & Routing

`index.php` reads `$_SESSION['privilege']` and redirects:
- `administrator` → `/manager/indexadmin.php` (admin dashboard)
- authenticated member → `/memstock/indexmem.php` (member dashboard)
- unauthenticated → `/main/loginform.php` (login page)

There is no URL router. Each page is a standalone PHP file.

### Module Directories

| Directory | Audience | Purpose |
|-----------|----------|---------|
| `main/` | Public / API | Login, public tour listing, REST-style API endpoints for mobile apps (`apigetproduct.php`, `apigettrx.php`), and all commission recalculation scripts (`calc*.php`) |
| `manager/` | Admin | Member approval, activation, commission management, reporting (~200+ files) |
| `memstock/` | Member | Member dashboard, tour booking, e-wallet, product purchasing (~100+ files) |
| `masterdata/` | Admin | CRUD for tours, products, programs, banks, geography |
| `expedition/` | Admin/Member | Shipping cost calculation via RajaOngkir API |
| `classes/` | Shared | All business logic classes |
| `framework/` | Shared | Blade-syntax template fragments (nav, sidebar, footer buttons) |
| `server/` | Shared | Database config and session bootstrap |

### Class Layer (`classes/`)

Classes are loaded via manual `include_once` at the top of each page file. Key classes:

| Class file | Responsibility |
|------------|---------------|
| `phplib.php` | `DB_MySQL` — legacy database abstraction wrapping deprecated `mysql_*` API. All queries go through `$db->query()`, `$db->fetchrow()`, etc. |
| `memberclass.php` | Member CRUD, login validation, profile management |
| `networkclass.php` | Upline/downline tree traversal for MLM structure (`tb_updown` table) |
| `komisiclass.php` | Commission/bonus calculation engine |
| `jualclass.php` | Sales and transaction processing |
| `productclass.php` | Product catalog management |
| `ruleconfigclass.php` | Business rule configuration (rates, eligibility, program configs) |
| `pulsaclass.php` | Mobile pulsa / PPOB (utility bill) payments |
| `actionpayclass.php` | Payment processing and e-wallet operations |
| `systemclass.php` | Utilities, audit logging |
| `dateclass.php` | Date/period utilities |
| `ifaceclass.php` | UI formatting helpers |

### Database Connections

Multiple named connections are used simultaneously within a single page. All are instances of `DB_MySQL` from `classes/phplib.php`, instantiated globally in `server/config.php`:

- `$db` / `$dbin` / `$db1` / `$dbin1` — primary and secondary read/write connections
- `$dbmenu` / `$dbmenuin` — menu/navigation queries
- `$dbtime`, `$oDB` — utility connections
- `$oDBAMHT` / `$oDBAMHTIn` — connects to a separate shared `amhtechn_amhtechno` database

There is also a raw `$conn` handle opened via `mysql_connect()` (used by legacy code that doesn't go through `DB_MySQL`).

### Template System

UI uses Blade-syntax fragments from `framework/` (e.g., `manager_topnav.blade.php`, `manager_sidebar.blade.php`) but this is **not Laravel** — the fragments are plain PHP with Blade-like variable syntax rendered directly, not via a Blade engine.

### Key Database Tables

| Table | Description |
|-------|-------------|
| `m_anggota` | Member/user profiles |
| `m_admin` | Administrator accounts |
| `tb_updown` | MLM upline/downline relationships |
| `m_product` | Product catalog |
| `m_tour` / `m_paket` | Tour packages |
| `m_program` | Marketing program definitions |
| `tb_penjualan` | Sales transactions |
| `tb_trxpulsa` | Pulsa/PPOB transactions |
| `m_menu` | Dynamic menu configuration per privilege level |
| `m_kotav`, `m_propinsi` | Geography (cities, provinces) |

## Code Patterns

- **No namespaces, no autoloading** — every file manually `include_once`s its dependencies.
- **Procedural with class containers** — classes exist but are used as function groupings, not encapsulated objects.
- **Legacy `mysql_*` API** in `classes/phplib.php` — this requires PHP ≤ 5.6 or a compatibility shim. Do not upgrade this to `mysqli`/PDO without testing the entire query layer.
- **Direct SQL string interpolation** — queries are built by concatenating `$_POST`/`$_GET` values directly. Be careful not to introduce new injection surfaces when adding features.
- **Session-based auth** — privilege and identity are stored in `$_SESSION` set during login.
- **Multi-environment via hostname** — `server/config.php` switches DB credentials based on `$_SERVER['SERVER_NAME']`.
- **Commission calc files** — `main/calc*.php` files (e.g., `calculatepair.php`, `calcday.php`, `calcftrans.php`) are standalone scripts that recalculate bonuses for a given period. They accept `uStart` and `uDate` GET params, and are triggered via HTTP by a cron job or manually — not from the UI.
- **Cron job** — defined in `cron/cron.txt`. The only active cron on production runs `main/deltemp.php?op=delete` daily at midnight to clean up temp files. Commission recalc scripts were previously scheduled externally but must be triggered manually now.
- **Class version snapshots** — `classes/Live_*/` subdirectories are timestamped backups of the class files at past deployment points. Do not edit these; they are reference archives only.
- **`pxx/`** — contains a bundled phpMyAdmin installation used for direct DB administration on the server.
- **Additional classes** — beyond the core list: `shopclass.php` (cart/shop logic), `espayclass.php` (e-payment gateway integration), `antaclass.php` (Antasena courier integration), `imageclass.php` (image upload/resize), `prefixclass.php` (member ID prefix rules), `processtrans.php` (transaction processing helpers), `shopclass.php` (product shop flow).

## Agent Capabilities

### Image Reading & Analysis (Juli 2026)

Agent mampu membaca dan menganalisis image dengan kemampuan berikut:

1. **UI Screenshot Analysis** — Agent bisa membaca screenshot halaman web yang dikirim user (PNG, JPEG, WebP, GIF) untuk:
   - Debug bug UI/layout (misal: tabel terpotong, modal tidak muncul, CSS rusak)
   - Membaca error message dari console / alert / notifikasi di halaman
   - Membandingkan tampilan sebelum-sesudah perubahan kode

2. **Project Asset Inspection** — Agent bisa membaca file image di dalam workspace `Z:\ProjectsX\AMHIntern` menggunakan tool `read_image`:
   - Path umum image produk: `images/product/`, `images/tour/`, `images/member/`
   - KTP / foto member: lokasi biasanya di folder `upload/` atau `fileupload/`
   - Gambar template struk, banner, logo di `framework/images/` atau `assets/`
   - Supported: `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`
   - Image akan otomatis divalidasi dan di-downscale jika terlalu besar

3. **OCR / Text Extraction** — Agent bisa mengekstrak teks dari image menggunakan vision capability, berguna untuk:
   - Baca KTP member saat verifikasi data
   - Baca struk transfer / bukti pembayaran
   - Baca screenshot pesan WhatsApp / chat untuk input data manual
   - Baca screenshot error log / stack trace dari browser

4. **Image Generation / Editing** — Agent bisa generate atau edit image menggunakan AI image tools (DALL-E / image generation) ketika user meminta:
   - Generate banner promo
   - Generate mockup UI untuk desain
   - Edit image produk (resize, crop via prompt)

### Cara Pakai
- Kirim image langsung via chat (drag-drop atau paste) untuk UI screenshot
- Sebut path file (contoh: `images/product/foto123.jpg`) untuk baca image di project
- Untuk OCR, cukup kirim image + instruksi "extract teks dari ini"
- Untuk generate, minta dengan prompt deskriptif (contoh: "buatkan banner promo MLM hijau-emas")

## Current Task Status (June 2026)

### Done
- **PO Approval (approvesell.php)**:
  - Fixed count and pagination queries in [manager/approvesell.php](file:///Z:/ProjectsX/AMHIntern/manager/approvesell.php) to correctly union and count distinct `fidpenjualan` from `tb_penjualan`, `tb_penjualan_temp`, and `tb_penjualan_temp_out`.
  - Added database-level seller filtering (`fidseller`) when logged-in user is a seller to prevent empty rows on page limit.
  - Corrected pagination page numbers link target from `historypo.php` to `approvesell.php`.
- **Detail Pembelian (detjual.php)**:
  - Fixed display of "Alamat Kirim" (`frecname`, `falamatkrm`) and "HP No" (`frecnohp`) for pending referral orders (`tb_penjualan_temp_out`) by querying database directly via union of the three main tables in [detjual.php](file:///Z:/ProjectsX/AMHIntern/memstock/detjual.php).
- **Integrasi Chat AI (Juli 2026)**:
  - Merancang `Bahan/recommendation_ai.md` sebagai panduan integrasi AI.
  - Membuat UI widget chat interaktif di `framework/chat_widget.blade.php`.
  - Membuat backend proxy ke Gemini API (`gemini-flash-latest`) di `main/api_chat.php` (memanfaatkan metode `file_get_contents` untuk mem-bypass error `cURL SSL 20`).
  - Menginjeksi widget secara global ke halaman login (`main/loginform.php`) dan admin/member (`framework/admin_footside.blade.php`).

- **MCP Database Integration (Juli 2026)**:
  - Agent memiliki koneksi MCP bernama `php-mysql-bridge` (juga dikenal sebagai "razor") yang dapat mengakses database langsung lewat eksekusi proxy PHP (`myrzrbrdg.php`).
  - MCP ini bisa digunakan untuk mengakses `amhtechn_intern`, `amhtechn_intrial`, dan `amhtechn_intrain`.
  - Tools MCP ini bisa dipanggil menggunakan `call_mcp_tool` (dengan tool name `execute_query` atau `execute_update`) atau dijalankan via Node CLI (`node C:\Users\didit\.gemini\antigravity-cli\mcp\php-mysql-bridge\index.js`) jika belum terload ke system.
  - **Di DSH Desktop**: MCP bridge tidak bisa dipanggil langsung via PowerShell (Windows SSL/Schannel error). Gunakan **Node.js inline script** dengan `https` module dan `rejectUnauthorized: false` untuk bypass SSL. Format request: `application/x-www-form-urlencoded` dengan field `service_password`, `host`, `port`, `user`, `password`, `database`, `action` (`Statement::executeQuery` atau `Statement::executeUpdate`), `query`, `fetchSize`, `fetchAll`. Response format: `|COLUMNS|col1!~!col2!~!|VALUES|val1!~!val2!~!|END_ROW|`.

- **Bonus Hasil Penjualan — Perubahan ke Persentase (Juli 2026)**:
  - **Sebelum**: `fbnssponhp` di `tb_rules_bnskorwil` berisi nominal flat (misal `5000` = Rp 5.000 langsung).
  - **Sesudah**: `fbnssponhp` berisi **persentase dari fee AMH (fpotong)**. Contoh: `fbnssponhp=50` artinya 50% dari total fee AMH.
  - **Rumus baru**: `Bonus = (Σ fsubtotal × fpotong/100) × fbnssponhp/100`. Dimana `fpotong` dari `m_product`, `fbnssponhp` dari `tb_rules_bnskorwil` (via `m_product.fprogram = tb_rules_bnskorwil.fidprogram`).
  - **Contoh**: Zamzam 2×100.000=200.000, fpotong=5% → fee AMH=10.000, fbnssponhp=50% → bonus=5.000.
  - Perubahan kode di [manager/processing_ajax.php](file:///Z:/ProjectsX/AMHIntern/manager/processing_ajax.php) blok `approvesell && kind=prd`:
    - Variabel `$vSellBonusAmt` (nominal flat) diganti `$vSellBonusRate` (persentase).
    - Bonus dihitung setelah `$vFeeAminah` terkumpul dari loop item: `$vSellBonusAmt = $vFeeAminah * $vSellBonusRate / 100`.
    - Deskripsi mutasi di `tb_mutasi` dibuat transparan: `"Bonus hasil penjualan J... (50% x 10.000)"`.
    - Potongan admin fee (`fbyyadmin%`) dari bonus tetap tidak berubah.
  - **Admin perlu update** nilai `fbnssponhp` di `tb_rules_bnskorwil` dari nominal (misal `5000`) ke persentase (misal `50`) secara manual.
