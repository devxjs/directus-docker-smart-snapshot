const fs = require("fs");
const path = require("path");
const fetch = require("node-fetch");

require('dotenv').config({
    path: path.join(__dirname, "../.env.local")
});

function getCurrentVersion() {
    const versionFilePath = path.join(__dirname, "../snapshots", "version.txt");
    if (fs.existsSync(versionFilePath)) {
        const version = parseInt(fs.readFileSync(versionFilePath, "utf-8"));
        if (!isNaN(version)) {
            return version;
        }
    }
    return 0;  // Si le fichier de version n'existe pas, commencer à partir de 1
}

function updateVersionFile(newVersion) {
    const versionFilePath = path.join(__dirname, "../snapshots", "version.txt");
    fs.writeFileSync(versionFilePath, newVersion.toString());
}


async function hasSnapshotDiff() {
    const diffURL = `${process.env.DIRECTUS_URL}/schema/diff?access_token=${process.env.DIRECTUS_ADMIN_STATIC_TOKEN}`;

    const currentVersion = getCurrentVersion();  // Obtenir le numéro de version actuel

    const lastSnapshotFilePath = path.join(__dirname, "../snapshots", `snapshot-${currentVersion}.json`);
    if (!fs.existsSync(lastSnapshotFilePath)) {
        return true
    }

    const snapshotData = fs.readFileSync(lastSnapshotFilePath, "utf-8");

    const response = await fetch(diffURL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: snapshotData,
    });

    if (response.status === 204) {
        return false
    }

    return true
}


async function registerSnapshot() {
    const URL = `${process.env.DIRECTUS_URL}/schema/snapshot?access_token=${process.env.DIRECTUS_ADMIN_STATIC_TOKEN}&export=json`;

    const response = await fetch(URL);
    const jsonData = await response.json();

    const currentVersion = getCurrentVersion();  // Obtenir le numéro de version actuel
    const newVersion = currentVersion + 1;

    // Définir le chemin du dossier et le chemin du fichier
    const folderPath = path.join(__dirname, "../snapshots");
    const filePath = path.join(folderPath, `snapshot-${newVersion}.json`);

    // Créer le dossier s'il n'existe pas
    if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
    }

    // Écrire les données JSON dans le fichier
    fs.writeFileSync(filePath, JSON.stringify(jsonData, null, 2));

    // Mettre à jour le fichier de version
    updateVersionFile(newVersion);
}

async function app() {
    const _hasSnapshotDiff = await hasSnapshotDiff();
    if (_hasSnapshotDiff) {
        await registerSnapshot();  // Enregistre la snapshot si nécessaire
        const snapshotPath = path.join(__dirname, "../snapshots", `snapshot-${getCurrentVersion()}.json`);
        return snapshotPath;
    }
    return null;
}


(async () => {
    const snapshotPath = await app();
})();