# 🚀 Instalasi & Konfigurasi CMS C-Data + WireGuard (Ubuntu 24.04)

Dokumentasi ini terbagi menjadi 2 bagian:

1. **Instalasi & Manajemen CMS C-Data**
2. **Setup WireGuard Server (VPS) & Client (Mikrotik)**

---

## 📦 Bagian A — Instalasi & Manajemen CMS C-Data

### 1. Persyaratan Minimum

- **OS**: Ubuntu 24.04 (Wajib)
- **CPU**: 2 Core
- **RAM**: 8 GB
- **Free Disk Space**: 64 GB

---

### 2. Buat Folder Instalasi CMS

```bash
sudo timedatectl set-timezone Asia/Jakarta && sudo mkdir -p /opt/cms && sudo chmod -R 755 /opt/cms && cd /opt/cms
```

> Folder `/opt/cms` adalah lokasi default instalasi.

---

### 3. Install Docker

```bash
wget https://raw.githubusercontent.com/andrydtm/cms/refs/heads/main/install_docker.sh && sudo chmod +x install_docker.sh && sudo ./install_docker.sh
```

> Script ini otomatis menginstall Docker & Docker Compose.

---

### 4. Download & Install CMS

```bash
sudo curl -o cms_install.sh https://cms.s.cdatayun.com/cms_linux/cms_install.sh && sudo chmod +x ./cms_install.sh && sudo ./cms_install.sh install --version 3.6.26
```

- Saat ini versi yang di install adalah versi `3.6.26`.  

---

### 5. Upgrade CMS

```bash
cd /opt/cms && sudo ./cms_install.sh upgrade --version <cms_version>
```

> Hanya dapat dijalankan di folder instalasi CMS.  
> Pastikan mengganti `<cms_version>` sebelum memulainya.

---

### 6. Reset Password Root CMS

```bash
cd /opt/cms && sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "source /reset_pwd/reset_pwd.sql"'
```

> Setelah reset password, **restart CMS**.

---

### 7. Reset Host CMS dengan Domain

```bash
cd /opt/cms && sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "update sys_tenant set ip = \"<host>\" "'
```

- Ganti `<host>` dengan:
  - Domain (contoh: `cms.example.com`)
- Restart CMS setelah menjalankan perintah ini.

---

### 8. Restart CMS

```bash
cd /opt/cms && sudo docker compose down && sudo docker compose up -d
```

---

### 9. Uninstall CMS

```bash
cd /opt/cms && sudo docker compose down && sudo rm -rf /opt/cms/*
```

---

### ⚠️ Catatan

- Login awal kadang butuh beberapa kali percobaan.
- Gunakan `sudo docker ps` untuk memastikan semua container CMS berjalan.
- Pastikan port CMS tidak bentrok dengan service lain.

---

## 🔒 Bagian B — Setup WireGuard

---

### Step 1 — Setup WireGuard Server (VPS)

#### 1. Install WireGuard

  ```bash
  sudo apt update -y && sudo apt install wireguard -y
  ```

---

#### 2. Generate Key Pair untuk Server
- Buat Folder Key Pair
  ```bash
  sudo mkdir -p /etc/wireguard/privatekeys /etc/wireguard/publickeys && sudo chmod 700 /etc/wireguard/privatekeys
  ```
- Buat Key Pair
  ```bash
  sudo sh -c 'PRIVATE_KEY=$(wg genkey) && echo "$PRIVATE_KEY" > /etc/wireguard/privatekeys/server_privatekey && echo "$PRIVATE_KEY" | wg pubkey > /etc/wireguard/publickeys/server_publickey'
  ```
- Lihat dan Simpan Key yang di Hasilkan
  ```bash
  echo "Private Key VPS:"; cat /etc/wireguard/privatekeys/server_privatekey; echo "Public Key VPS:"; cat /etc/wireguard/publickeys/server_publickey
  ```
  
---

#### 3. Konfigurasi WireGuard Server

Edit file konfigurasi WireGuard di VPS:

```bash
sudo nano /etc/wireguard/wg0.conf
```

**Isi file `wg0.conf`:**

```ini
[Interface]
Address = 10.10.10.1/24
PrivateKey = <PRIVATE_KEY_VPS>
ListenPort = 51820

[Peer]
PublicKey = <PUBLIC_KEY_MIKROTIK>
AllowedIPs = 10.10.10.2/32, <IP_LOKAL_TAMBAHAN>
PersistentKeepalive = 25
```

**Catatan:**
  > 1. Pastikan `<PRIVATE_KEY_VPS>` dan `<PUBLIC_KEY_MIKROTIK>` diganti sesuai hasil generate key masing-masing.
  > 2. Sebaiknya lakukan **Step 2 — Setup WireGuard Client (Mikrotik)** terlebih dahulu untuk mendapatkan public key Mikrotik.
  > 3. `<IP_LOKAL_TAMBAHAN>` bisa diisi jika ingin melewatkan routing IP lokal tertentu melalui tunnel WireGuard.

---

#### 4. Aktifkan IP Forwarding & NAT

```bash
sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && sudo iptables -A FORWARD -i wg0 -j ACCEPT && sudo iptables -A FORWARD -o wg0 -j ACCEPT
```

- ***Jadikan Permanen***
  
  ```bash
  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p && sudo apt install iptables-persistent -y && sudo netfilter-persistent save
  ```

---

#### 5. Start WireGuard

```bash
sudo systemctl restart wg-quick@wg0 && sudo systemctl enable wg-quick@wg0 && sudo systemctl status wg-quick@wg0
```

---

#### 6. Buka Port Firewall

```bash
sudo ufw allow 51820/udp && sudo ufw reload
```

---

### Step 2 — Setup WireGuard Client (Mikrotik)

#### 1. Tambahkan Interface WireGuard

```bash
/interface wireguard add name=wg0 listen-port=51820
```

---

#### 2. Lihat Private & Public Key Mikrotik

```bash
/interface wireguard print detail
```
- Lihat dan Simpan Key yang di Hasilkan
---

#### 3. Tambahkan IP Address di Interface

```bash
/ip address add address=10.10.10.2/24 interface=wg0 comment="WireGuard"
```

---

#### 4. Tambahkan Peer (Hubungkan ke VPS)

```bash
/interface wireguard peers
add name=peer_wg0 \
    interface=wg0 \
    public-key="PUBLIC_KEY_VPS" \
    endpoint-address=<IP_VPS> \
    endpoint-port=51820 \
    allowed-address=10.10.10.0/24,<IP_LOKAL_TAMBAHAN> \
    persistent-keepalive=25s
```

- Ganti `PUBLIC_KEY_VPS` dengan publik key VPS.
- Ganti `<IP_VPS>` dengan IP publik VPS.
- `<IP_LOKAL_TAMBAHAN>` untuk route IP lokal tertentu lewat WireGuard.

---

## ✅ Tips

- Cek koneksi WireGuard di VPS:
  ```bash
  sudo wg show
  ```
  > Ping WG Client Mikrotik Di VPS
  ```bash
  ping -c 3 10.10.10.2
  ```
- Cek koneksi WireGuard di Mikrotik:
  ```bash
  /interface/wireguard/peers/print
  ```
  > Ping WG Server VPS di Mikrotik
  ```bash
  ping -c 3 10.10.10.1
  ```

---
