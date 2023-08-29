const fs = require("fs");
const path = require("path");
const fetch = require("node-fetch");

require('dotenv').config({
    path: path.join(__dirname, "../.env.local")
});

async function getSnapshotDiff(snapshotPath) {
    const diffURL = `${process.env.DIRECTUS_URL}/schema/diff?access_token=${process.env.DIRECTUS_ADMIN_STATIC_TOKEN}`;
    
    const snapshotData = fs.readFileSync(snapshotPath, "utf-8");
    
    const response = await fetch(diffURL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: snapshotData,
    });
    
    if (response.status === 200) {
        return await response.json();
    } else {
        console.error("Failed to get snapshot diff.");
        console.error(await response.text());
        return null;
    }
}

async function applySnapshotDiff(snapshotDiff) {
    const applyURL = `${process.env.DIRECTUS_URL}/schema/apply?access_token=${process.env.DIRECTUS_ADMIN_STATIC_TOKEN}`;

    const response = await fetch(applyURL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(snapshotDiff.data),
    });

    if (response.status === 200 || response.status === 204) {
        console.log("Snapshot diff applied successfully.");
    } else {
        console.error("Snapshot diff application failed.");
        console.error(await response.text());
    }
}

async function getLastSnapshotPath() {
    const versionFilePath = path.join(__dirname, "../snapshots", "version.txt");
    const currentVersion = parseInt(fs.readFileSync(versionFilePath, "utf-8"));

    if (!isNaN(currentVersion)) {
        const lastSnapshotPath = path.join(__dirname, "../snapshots", `snapshot-${currentVersion}.json`);
        if (fs.existsSync(lastSnapshotPath)) {
            return lastSnapshotPath;
        }
    }

    return null;
}

async function main() {
    const lastSnapshotPath = await getLastSnapshotPath();

    if (lastSnapshotPath) {
        const snapshotDiff = await getSnapshotDiff(lastSnapshotPath);
        if (snapshotDiff) {
            await applySnapshotDiff(snapshotDiff);
        }
    } else {
        console.log("No snapshots found to apply.");
    }
}

main();
