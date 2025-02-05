#!/usr/bin/env node

const cache = require('@buildpulse/cache');
const { Command } = require('commander');

async function save() {
  const primaryKey = process.env.INPUT_KEY;
  const cachePaths = process.env.INPUT_PATHS.split(" ");
  const uploadChunkSize = parseInt(process.env.INPUT_UPLOAD_CHUNK_SIZE);
  const enableCrossOsArchive = true;

  const cacheId = await cache.saveCache(
    cachePaths,
    primaryKey,
    { uploadChunkSize: uploadChunkSize },
    enableCrossOsArchive
  );

  if (cacheId != -1) {
    console.log(`Cache saved with key: ${primaryKey}`);
  }
}

async function restore() {
  const primaryKey = process.env.INPUT_KEY;
  const failOnCacheMiss = process.env.INPUT_FAIL_ON_CACHE_MISS === "true";
  const enableCrossOsArchive = true;
  const cachePaths = process.env.INPUT_PATHS.split(" ");
  const restoreKeys = [];

  const cacheKey = await cache.restoreCache(
    cachePaths,
    primaryKey,
    restoreKeys,
    { lookupOnly: false },
    enableCrossOsArchive
  );


  if (!cacheKey) {
    if (failOnCacheMiss) {
      throw new Error(
        `Failed to restore cache entry. Exiting as fail-on-cache-miss is set. Input key: ${primaryKey}`
      );
    }
    console.log(`Cache not found for input keys: ${primaryKey}`);

    return;
  }
}

const program = new Command();

program
  .command('save')
  .description('Save a file or directory to BuildPulse Cache')
  .action(save);

program
  .command('restore')
  .description('Restore a file or directory from BuildPulse Cache')
  .action(restore);

program.parse(process.argv);
