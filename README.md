# remote-backup
Powerhosting remote-backup til 

HETZNER SETUP: (https://www.hetzner.com/storage/storage-box)

1) Aktiver SSH-support
2) Aktiver automatic snapshots. Sættes til daily og kørselstid fx. omkring middag for at sikre backupkørsler når at blive færdige. Maksimum snapshots sættes efter personlig præference.



POWERHOSTING SERVER SETUP:

1) Tjek om der alleredes findes en pubkey. Er det ikke tilfældet køres:
ssh-keygen -t ed25519 -C "identifier fx. navnet på sitet"

2) Herefter installeres den nye pubkey på storage boxen hos Hetzner:
cat ~/.ssh/id_ed25519.pub | ssh -p23 INDSÆT-USERNAME@INDSÆT-SERVER install-ssh-key
