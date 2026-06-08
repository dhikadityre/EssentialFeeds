# GitHub Actions CI

Dokumen ini menjelaskan langkah membuat CI GitHub Actions untuk menjalankan build dan test project `EssentialFeed` sebelum perubahan digabungkan ke branch utama.

## Struktur File

Buat folder dan file berikut dari root project:

```sh
mkdir -p .github/workflows
touch .github/workflows/ci.yml
```

Strukturnya menjadi:

```txt
essential-feeds/
├── .github/
│   └── workflows/
│       └── ci.yml
├── EssentialFeed.xcodeproj
├── EssentialFeed/
├── EssentialFeedTests/
└── CI.xctestplan
```

## Isi Workflow

File `.github/workflows/ci.yml` berisi workflow yang berjalan saat ada `push` ke `main`/`master` dan saat ada `pull_request`.

```yml
name: CI

on:
  push:
    branches:
      - main
      - master
  pull_request:

jobs:
  build-and-test:
    name: Build and test
    runs-on: macos-26
    timeout-minutes: 20

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Build and test
        run: |
          set -o pipefail
          xcodebuild clean build test \
            -project EssentialFeed.xcodeproj \
            -scheme "CI" \
            -destination "platform=macOS" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO
```

Catatan:
- `runs-on: macos-26` dipakai karena project menggunakan Xcode/macOS terbaru.
- `-scheme "CI"` memakai shared scheme `CI` yang ada di `EssentialFeed.xcodeproj/xcshareddata/xcschemes/CI.xcscheme`.
- `-destination "platform=macOS"` membuat target test eksplisit untuk macOS.
- `CODE_SIGNING_ALLOWED=NO` dan `CODE_SIGNING_REQUIRED=NO` mencegah CI gagal karena tidak punya signing certificate.

## Pengujian Di Local Machine

Sebelum push ke remote, jalankan command yang sama dari root project:

```sh
xcodebuild clean build test \
  -project EssentialFeed.xcodeproj \
  -scheme "CI" \
  -destination "platform=macOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
```

Jika berhasil, output akhir biasanya berisi:

```txt
** TEST SUCCEEDED **
```

Untuk memastikan scheme `CI` tersedia:

```sh
xcodebuild -list -project EssentialFeed.xcodeproj
```

Pastikan bagian `Schemes` menampilkan:

```txt
CI
EssentialFeed
```

## Checklist Sebelum Push

Jalankan checklist berikut sebelum push:

- Pastikan command `xcodebuild clean build test ...` berhasil di local machine.
- Pastikan file `.github/workflows/ci.yml` sudah masuk git.
- Pastikan shared scheme `CI` tersedia di `EssentialFeed.xcodeproj/xcshareddata/xcschemes/`.
- Commit perubahan CI dan dokumentasi.
- Push branch ke remote GitHub.
- Buka tab `Actions` di GitHub untuk melihat workflow `CI`.

## Fallback Dengan Travis CI

Project ini juga bisa menyimpan `.travis.yml` sebagai CI cadangan. GitHub Actions dan Travis dapat berjalan paralel.

Jika salah satu provider sedang maintenance:

- Gunakan provider yang masih sehat untuk validasi build/test.
- Di GitHub branch protection, ubah required status check ke CI provider yang sedang aktif.
- Setelah provider yang maintenance normal kembali, required check bisa dikembalikan sesuai kebutuhan.

