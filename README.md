# 🚀 Instalasi CMS C-Data (Wajib Ubuntu 24.04)

## Persyaratan Minimum
- **CPU**: 2 Core
- **Memori**: 8 GB
- **Free Hard Disk Space**: 64 GB

---

## 1. Buat Folder CMS
```bash
sudo mkdir -p /opt/cms \
&& sudo chown -R $USER:$USER /opt/cms \
&& sudo chmod -R 755 /opt/cms \
&& cd /opt/cms
```

---

## 2. Install Docker
```bash
wget https://raw.githubusercontent.com/andrydtm/cms/refs/heads/main/install_docker.sh \
&& sudo chmod +x install_docker.sh \
&& sudo ./install_docker.sh
```

---

## 3. Download & Install CMS
```bash
sudo curl -o cms_install.sh https://cms.s.cdatayun.com/cms_linux/cms_install.sh \
&& sudo chmod +x ./cms_install.sh \
&& sudo ./cms_install.sh install --version <cms_version>
```
> **Versi saat ini:** `3.6.26`  
> Saat diminta untuk memilih opsi, jika ragu **pilih `n` (tidak)**.

---

## 4. Upgrade CMS
```bash
cd /opt/cms \
&& sudo ./cms_install.sh upgrade --version <cms_version>
```
> Pastikan mengganti **`<cms_version>`** dengan versi CMS yang ingin digunakan.  
> Upgrade CMS **hanya bisa dilakukan di folder instalasi CMS**.

---

## 5. Reset Root Password
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "source /reset_pwd/reset_pwd.sql"'
```
> Setelah mereset root password, **restart CMS**.

---

## 6. Reset CMS Host
```bash
cd /opt/cms \
&& sudo docker exec -it cms-mysql sh -c 'mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" ccssx_boot -e "update sys_tenant set ip = \"<host>\" "'
```
> Ganti **`<host>`** dengan host yang diinginkan.  
> Setelah mereset host, **restart CMS**.

---

## 7. Restart CMS
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo docker compose up -d
```

---

## 8. Uninstall CMS
```bash
cd /opt/cms \
&& sudo docker compose down \
&& sudo rm -rf /opt/cms/*
```

---

## ⚠️ Catatan
- Login awal mungkin agak sulit — **coba beberapa kali hingga berhasil**.  
- Folder instalasi default adalah **`/opt/cms`**, tetapi dapat disesuaikan sesuai kebutuhan.

---

# 🚀  Install SSL Untuk CMS

---

## 1. Install Certbot di Ubuntu 24.04
```bash
cd ~ \
&& sudo apt update -y \
&& sudo apt install certbot -y
```

---

## 2. Dapatkan Sertifikat untuk Domain
```bash
cd ~ \
&& sudo certbot certonly --standalone -d cms.example.com
```
> Setelah selesai, sertifikat akan tersimpan di: /etc/letsencrypt/live/cms.example.com/
---

## 3. Copy sertifikat ke folder CMS
```bash
cd /opt/cms \
&& sudo cp /etc/letsencrypt/live/cms.example.com/fullchain.pem /opt/cms/certs/nginx/ \
&& sudo cp /etc/letsencrypt/live/cms.example.com/privkey.pem /opt/cms/certs/nginx/ \
&& sudo chown $USER:$USER /opt/cms/certs/nginx/*.pem
```

---

## 4. Aktifkan HTTPS di CMS
```bash
cd /opt/cms \
&& sudo ./cms.sh https enable --port 443 --server-name cms.example.com --cert fullchain.pem --cert-key privkey.pem
```

---

## 5. (Opsional) Perpanjang otomatis
```bash
cd ~ \
&& sudo crontab -e
```
### Tambahkan
```swift
0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/cms.example.com/fullchain.pem /opt/cms/certs/nginx/ && cp /etc/letsencrypt/live/cms.example.com/privkey.pem /opt/cms/certs/nginx/ && cd /opt/cms && ./cms.sh https enable --port 443 --server-name cms.example.com --cert fullchain.pem --cert-key privkey.pem
```
---

# 🚀  Step 1: Setup WireGuard Server di VPS

---

## 1. Install WireGuard

```bash
cd ~ \
&& sudo apt update -y \
&& sudo apt install wireguard -y
```

---

## 2. Generate key pair untuk server

```bash
cd ~ \
&& wg genkey | tee server_privatekey | wg pubkey > server_publickey
```
> cat server_privatekey akan berisi private key server.  
> cat server_publickey akan berisi public key server.

---

## 3. Buat konfigurasi WireGuard
```bash
cd ~ \
&& sudo nano /etc/wireguard/wg0.conf
```
### Tambahkan
```ini
[Interface]
Address = 10.10.0.1/16         # IP VPN Server
ListenPort = 51820              # Port WireGuard server
PrivateKey = <Privatekey_VPS>

# Nanti diisi setelah punya public key dari Mikrotik
#[Peer]
#PublicKey = <PUBKEY_DARI_MIKROTIK>
#AllowedIPs = 10.10.0.2/32,<Tambahkan IP Lokal dan Pisahkan Dengan Koma contoh 192.168.10.0/24,10.100.0.0/16>
#PersistentKeepalive = 25
```
### Restart WireGruad
```bash
cd ~ \
&& sudo wg-quick down wg0 \
&& sudo wg-quick up wg0
```
---

## 4. Aktifkan IP forwarding
```bash
cd ~ \
&& sudo sysctl -w net.ipv4.ip_forward=1 \
&& sudo iptables -t nat -A POSTROUTING -s 10.10.0.1/16 -o eth0 -j MASQUERADE \
&& sudo iptables -t nat -A POSTROUTING -s 10.100.0.1/16 -o eth0 -j MASQUERADE
&& sudo iptables -t nat -A POSTROUTING -s 10.88.0.1/16 -o eth0 -j MASQUERADE
```
### Cek iptables:
```bash
cd ~ \
&& sudo iptables -t nat -L -n -v
```
### Cek NAT POSTROUTING
```bash
cd ~ \
&& sudo iptables -t nat -L POSTROUTING -n -v --line-numbers
```
### Menghapus NAT POSTROUTING Double
```bash
cd ~ \
&& sudo iptables -t nat -D POSTROUTING <Angka ID>
```
### Agar Permanen
```bash
cd ~ \
&& sudo nano /etc/sysctl.conf
```
> Hapus Komentar (#) Pada net.ipv4.ip_forward=1
### Lanjut Permanet
```bash
cd ~ \
&& sudo apt install iptables-persistent -y \
&& sudo netfilter-persistent save
```

---

## 5. Start WireGuard
```bash
cd ~ \
&& sudo wg-quick up wg0 \
&& sudo systemctl enable wg-quick@wg0
```

---

## 6. Set firewall untuk buka port 51820 dan port CMS 9909
```bash
cd ~ \
&& sudo ufw allow 51820/udp \
&& sudo ufw allow 9909/udp \
&& sudo ufw reload
```
>Tambahkan peer (client Mikrotik) nanti setelah konfigurasi Mikrotik siap

---

## 7. Pastikan routing di VPS
> Kalau misalnya OLT ada di subnet 10.100.0.0/16, pastikan route-nya lewat wg0:
```bash
cd ~ \
sudo ip route add 10.100.0.0/16 dev wg0
```

---

# 🚀  Step 2: Setup WireGuard Client di Mikrotik

---

## 1. Tambah interface WireGuard
```bash
/interface wireguard add name=wg0 listen-port=51820
```

---

## 2. Lihat private key dan public key
```bash
/interface wireguard print detail
```

---

## 3. Tambahkan IP address
```bash
/ip address add address=10.10.0.2/16 interface=wg0 comment="WireGuard"
```
### Cek IP Route
```bash
/ip route print
```

---

## 3. Tambahkan peer
```bash
/interface/wireguard/peers/add \
interface=wg0 \
public-key="PUBKEY_VPS" \
allowed-address=10.10.0.1/32,<Tambahkan IP Lokal dan Pisahkan Dengan Koma contoh 192.168.10.0/24,10.100.0.0/16 > \
endpoint-address=<IP_VPS> \
endpoint-port=51820 \
persistent-keepalive=25s
```

---

## 4. Pastikan firewall Mikrotik izinkan port WireGuard
```bash
/ip firewall filter
add chain=input protocol=udp dst-port=51820 action=accept comment="Izinkan Port WireGuard"
```

---

## 5. Pastikan firewall Mikrotik Izin TR-069 ke ACS
```bash
/ip firewall filter
add chain=forward dst-address=<IP_VPS> protocol=tcp dst-port=9909 action=accept comment="Allow outbound TR-069 ke ACS"
add chain=forward src-address=<IP_VPS> protocol=tcp src-port=9909 action=accept comment="Allow inbound TR-069 dari ACS"
```

---

## 6. Mengizinkan forward dari WireGuard ke VLAN
```bash
/ip firewall filter
add chain=forward src-address=10.10.0.0/16 dst-address=10.100.0.0/16 action=accept comment="WireGuard Ke VLAN100"
add chain=forward src-address=10.100.0.0/16 dst-address=10.10.0.0/16 action=accept comment="VLAN100 KE WireGuard"

```
### Contoh
> IP WireGuard = 10.10.0.0/16  
> IP VLAN100 = 10.100.0.0/16
---
