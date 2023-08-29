# Projet Backend Directus

Suivez les étapes ci-dessous pour configurer et exécuter le projet localement.

## Prérequis

Assurez-vous d'avoir Node.js et npm (Node Package Manager) installés sur votre système. Il est recommandé d'utiliser "nvm" pour gérer les versions de Node.js.

## Configuration

1. Configurez le fichier `.env.local` en vous basant sur le fichier `.env.example`. Ce fichier contiendra les variables d'environnement nécessaires à la configuration du projet. Assurez-vous d'y inclure toutes les valeurs requises avant de lancer l'installation.

## Installation

Avant d'installer le projet, veuillez bien configurer le fichier `.env.local`.

Pour installer le projet, activez les permissions d'exécution pour le script d'installation (`install.sh`) en exécutant :

```bash
chmod +x ./install.sh
```

Puis lancez le script en utilisant la commande suivante (le script nécessite le mot de passe sudo pour donner les permissions requises aux dossiers uploads, extensions et snapshots) :

```bash
./install.sh "<votre_mot_de_passe_sudo>"
```

## Lancement du projet

Une fois le script d'installation effectué, vous pouvez lancer le projet en exécutant le script `start.sh` :

```bash
./start.sh
```

## Versioning de la base de donnée (avant de push)

Lorsque que vous effectuez des changements en BO Directus qui vont affecter la structure de la base de donnée, n'oubliez pas de mettre à jour les snapshots avec la commande :

```bash
npm run schema:update
```

## Versioning de la base de donnée (après un pull)

Avant de commencer à travailler après une pull request veiller à vérifier que le schéma de votre base de donnée est à jour. Il est préférable de le mettre à jour avant de commencer à travailler pour éviter des conflits inutiles. Pour appliquer la dernière mise à jour a votre base de donnée il suffit de rentrer la commande :

```bash
npm run schema:apply
```