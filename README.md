# Nextcloud-Uzunov-sync

Nous avons un cloud nextcloud tout nos clients sont dans le groupe customer,
les employés de la compagnie partage un dossier client dossier dans le compte d'admin du nextcloud et partagé uniquement au groupe admin.

Le but du projet et de fournir aux clients en espace de stockage et d'échange de fichier.
Chaque client a dans sont "home" un dossier d'envoie et un dossier de reception.
Le dossier d'envoie se vide une fois les fichiers copier pour le groupe admin.

Dans notre cas nous avons besoin des outils suivant :

- docker pour nextcloud
- rsync
- python (next version)
- rclone
- git

## A faire avant:
Configurer le path de notre cloud externe (dans notre cas dropbox).
