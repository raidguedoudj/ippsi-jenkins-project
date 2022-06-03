# Jenkins

Parmètres attendus dans le job Jenkins :

- le lien du repository infrastructure (en configuration du job) => il sert à build les fichiers TF
- le lien du repository code (en paramètre à la main) => il sert à build l'application
- le lien du repository qui stocke les différentes infra installées dans le cloud

Faire des scripts de génération des fichiers TF :
- `check_env.sh`
- `provider.sh`
- `network.sh`
- `security_groups.sh`
- `instances.sh`

Nous appelons ces scripts depuis un script global

3 jobs différents :

1. Création de l'infra (sans déploiement de code)
2. Déploiement du code
3. Suppression de l'infra

