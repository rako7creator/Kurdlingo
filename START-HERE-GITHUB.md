# KurdLingo — editable project for your friend

This ZIP contains the full Godot 0.9 project, scripts, 3D assets, all audio, bilingual vocabulary and podcast scripts. This release includes the new school, shared podcast studio, scooter jump/boost and moving citizens. No account or speech API key is needed to run the included project.

## Open and edit

1. Extract this ZIP. Open the KurdLingo-source folder.
2. Install Godot 4.7.2, matching the version used for this project.
3. Import project.godot in Godot. Allow the first asset import to finish.
4. Press F6 to run the current scene, or F5 to run the game.
5. Edit scripts/*.gd for behavior; data/vocabulary.json for words; data/podcasts.json for episodes; scripts/daily_props.gd for the new object shapes; scripts/expansion_world.gd for themed environments; scripts/school_world.gd and scripts/school_props.gd for the academy; scripts/citizens.gd for walking NPCs.

Changing a spoken word or podcast paragraph also requires replacing its matching WAV recording under assets/audio/. Text edits alone do not regenerate speech. CSVs are review copies; the game reads the JSON data. Back up data before bulk translation changes.

## Put this project on GitHub

Install Git and Git LFS on both computers. Open a terminal inside KurdLingo-source, then run:

```sh
git init -b main
git lfs install
git add .
git commit -m "Add editable KurdLingo 0.9 project"
```

Create a new EMPTY private GitHub repository named KurdLingo. Do not initialize it with a README, license or gitignore because these files are already included. Copy that repository's HTTPS URL, then run (replace YOUR-USERNAME):

```sh
git remote add origin https://github.com/YOUR-USERNAME/KurdLingo.git
git push -u origin main
```

Sign in when Git requests authentication. Do not place a password or token in source files. The included .gitattributes tracks audio, 3D models and fonts using Git LFS. GitHub LFS usage is subject to your account's storage and bandwidth allowances; check those before uploading the complete asset collection.

On GitHub, use repository Settings > Collaborators to invite your friend's GitHub account. Your friend can clone with GitHub Desktop, or use:

```sh
git lfs install
git clone https://github.com/YOUR-USERNAME/KurdLingo.git
cd KurdLingo
git lfs pull
```

Your friend should import the cloned project's project.godot into Godot. If models or audio appear missing, run git lfs pull; LFS pointer files are not playable assets.

## Work together

Before starting work, pull the latest changes. Create a branch for an edit:

```sh
git switch -c improve-models
```

After testing in Godot:

```sh
git add .
git commit -m "Improve object models"
git push -u origin improve-models
```

Open a pull request on GitHub so you can review and merge your friend's edits. Each person should use their own branch. Avoid simultaneous edits to the same large audio/model file.

## Export Windows

Install Godot's matching export templates. Use Project > Export > Windows Desktop. The bundled export preset uses the standard template and has no dependency on the original owner's PC paths. Its default destination is ../Windows-KurdLingo-0.9/KurdLingo.exe; choose another destination if desired. Generated exports and saves are ignored by Git.

## Verify changes

The project includes integrated checks. From the project folder, using the Godot console executable available on your computer:

```sh
godot --headless --path . -- --self-test
```

Success prints SELF TEST PASS. Review translated text and listen to changed recordings separately; automated checks do not validate Sorani pronunciation or translation quality.

## Rights and privacy

Original code is MIT licensed. Keep LICENSE.txt, THIRD-PARTY-NOTICES.md and licenses/ in the repository. Sorani speech has noncommercial restrictions; this package does not grant commercial rights to every asset. Model weights and private user saves are excluded. Sorani text and pronunciation remain drafts for native-speaker review.

Official GitHub LFS instructions: https://docs.github.com/en/repositories/working-with-files/managing-large-files/configuring-git-large-file-storage
