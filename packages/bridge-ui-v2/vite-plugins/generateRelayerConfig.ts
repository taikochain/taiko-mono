/* eslint-disable no-console */
import dotenv from 'dotenv';
import { promises as fs } from 'fs';
import path from 'path';
import { Project, SourceFile, VariableDeclarationKind } from 'ts-morph';

import configuredRelayerSchema from '../config/schemas/configuredRelayer.schema.json';
import type { ConfiguredRelayer, RelayerConfig } from '../src/libs/relayer/types';
import { decodeBase64ToJson } from './utils/decodeBase64ToJson';
import { formatSourceFile } from './utils/formatSourceFile';
import { Logger } from './utils/Logger';
import { validateJsonAgainstSchema } from './utils/validateJson';

dotenv.config();

const pluginName = 'generateRelayerConfig';
const logger = new Logger(pluginName);

const currentDir = path.resolve(new URL(import.meta.url).pathname);

const outputPath = path.join(path.dirname(currentDir), '../src/generated/relayerConfig.ts');
// Decode base64 encoded JSON string
if (!process.env.CONFIGURED_RELAYER) {
  throw new Error('CONFIGURED_RELAYER is not defined in environment.');
}
const configuredRelayerConfigFile = decodeBase64ToJson(process.env.CONFIGURED_RELAYER || '');

// Valide JSON against schema
const isValid = validateJsonAgainstSchema(configuredRelayerConfigFile, configuredRelayerSchema);

if (!isValid) {
  throw new Error('encoded configuredBridges.json is not valid.');
}

export function generateRelayerConfig() {
  return {
    name: pluginName,
    async buildStart() {
      logger.info('Plugin initialized.');

      // Path to where you want to save the generated Typ eScript file
      const tsFilePath = path.resolve(outputPath);

      const project = new Project();
      const notification = `// Generated by ${pluginName} on ${new Date().toLocaleString()}`;
      const warning = `// WARNING: Do not change this file manually as it will be overwritten`;

      let sourceFile = project.createSourceFile(tsFilePath, `${notification}\n${warning}\n`, { overwrite: true });

      // Create the TypeScript content
      sourceFile = await storeTypesAndEnums(sourceFile);
      sourceFile = await buildRelayerConfig(sourceFile);

      await sourceFile.save();

      const formatted = await formatSourceFile(tsFilePath);
      console.log('formatted', tsFilePath);

      // Write the formatted code back to the file
      await fs.writeFile(tsFilePath, formatted);
      logger.info(`Formatted config file saved to ${tsFilePath}`);
    },
  };
}

async function storeTypesAndEnums(sourceFile: SourceFile) {
  logger.info(`Storing types...`);
  // RelayerConfig
  sourceFile.addImportDeclaration({
    namedImports: ['RelayerConfig'],
    moduleSpecifier: '$libs/relayer',
    isTypeOnly: true,
  });

  logger.info('Types stored.');
  return sourceFile;
}

async function buildRelayerConfig(sourceFile: SourceFile) {
  logger.info('Building relayer config...');

  const relayer: ConfiguredRelayer = configuredRelayerConfigFile;

  if (!relayer.configuredRelayer || !Array.isArray(relayer.configuredRelayer)) {
    console.error('configuredRelayer is not an array. Please check the content of the configuredRelayerConfigFile.');
    throw new Error();
  }

  // Create a constant variable for the configuration
  const relayerConfigVariable = {
    declarationKind: VariableDeclarationKind.Const,
    declarations: [
      {
        name: 'configuredRelayer',
        initializer: _formatObjectToTsLiteral(relayer.configuredRelayer),
        type: 'RelayerConfig[]',
      },
    ],
    isExported: true,
  };

  sourceFile.addVariableStatement(relayerConfigVariable);
  logger.info('Relayer config built.');
  return sourceFile;
}

const _formatRelayerConfigToTsLiteral = (config: RelayerConfig): string => {
  return `{chainIds: [${config.chainIds ? config.chainIds.join(', ') : ''}], url: "${config.url}"}`;
};

const _formatObjectToTsLiteral = (relayers: RelayerConfig[]): string => {
  return `[${relayers.map(_formatRelayerConfigToTsLiteral).join(', ')}]`;
};
