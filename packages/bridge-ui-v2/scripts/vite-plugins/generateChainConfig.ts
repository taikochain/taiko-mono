/* eslint-disable no-console */
import dotenv from 'dotenv';
import { promises as fs } from 'fs';
import path from 'path';
import { Project, SourceFile, VariableDeclarationKind } from 'ts-morph';

import configuredChainsSchema from '../../config/schemas/configuredChains.schema.json';
import type { ChainConfig, ChainConfigMap, ConfiguredChains } from '../../src/libs/chain/types';
import { decodeBase64ToJson } from './../utils/decodeBase64ToJson';
import { formatSourceFile } from './../utils/formatSourceFile';
import { PluginLogger } from './../utils/PluginLogger';
import { validateJsonAgainstSchema } from './../utils/validateJson';
dotenv.config();

const pluginName = 'generateChainConfig';
const logger = new PluginLogger(pluginName);

const skip = process.env.SKIP_ENV_VALDIATION || false;

const currentDir = path.resolve(new URL(import.meta.url).pathname);

const outputPath = path.join(path.dirname(currentDir), '../../src/generated/chainConfig.ts');

export function generateChainConfig() {
  return {
    name: pluginName,
    async buildStart() {
      logger.info('Plugin initialized.');
      let configuredChainsConfigFile;
      if (!skip) {
        if (!process.env.CONFIGURED_CHAINS) {
          throw new Error(
            'CONFIGURED_CHAINS is not defined in environment. Make sure to run the export step in the documentation.',
          );
        }
        // Decode base64 encoded JSON string
        configuredChainsConfigFile = decodeBase64ToJson(process.env.CONFIGURED_CHAINS || '');
        // Validate JSON against schema
        const isValid = validateJsonAgainstSchema(configuredChainsConfigFile, configuredChainsSchema);

        if (!isValid) {
          throw new Error('encoded configuredBridges.json is not valid.');
        }
      } else {
        configuredChainsConfigFile = '';
      }

      // Path to where you want to save the generated TypeScript file
      const tsFilePath = path.resolve(outputPath);

      const project = new Project();
      const notification = `// Generated by ${pluginName} on ${new Date().toLocaleString()}`;
      const warning = `// WARNING: Do not change this file manually as it will be overwritten`;

      let sourceFile = project.createSourceFile(tsFilePath, `${notification}\n${warning}\n`, { overwrite: true });

      // Create the TypeScript content
      sourceFile = await storeTypes(sourceFile);
      sourceFile = await buildChainConfig(sourceFile, configuredChainsConfigFile);
      await sourceFile.saveSync();

      const formatted = await formatSourceFile(tsFilePath);

      // Write the formatted code back to the file
      await fs.writeFile(tsFilePath, formatted);

      logger.info(`Formatted config file saved to ${tsFilePath}`);
    },
  };
}

async function storeTypes(sourceFile: SourceFile) {
  logger.info(`Storing types...`);

  // ChainConfigMap
  sourceFile.addImportDeclaration({
    namedImports: ['ChainConfigMap'],
    moduleSpecifier: '$libs/chain',
    isTypeOnly: true,
  });

  // LayerType
  sourceFile.addEnum({
    name: 'LayerType',
    isExported: false,
    members: [
      { name: 'L1', value: 'L1' },
      { name: 'L2', value: 'L2' },
      { name: 'L3', value: 'L3' },
    ],
  });

  logger.info('Types stored.');
  return sourceFile;
}

async function buildChainConfig(sourceFile: SourceFile, configuredChainsConfigFile: ConfiguredChains) {
  const chainConfig: ChainConfigMap = {};

  const chains: ConfiguredChains = configuredChainsConfigFile;

  if (!skip) {
    if (!chains.configuredChains || !Array.isArray(chains.configuredChains)) {
      console.error('configuredChains is not an array. Please check the content of the configuredChainsConfigFile.');
      throw new Error();
    }

    chains.configuredChains.forEach((item: Record<string, ChainConfig>) => {
      for (const [chainIdStr, config] of Object.entries(item)) {
        const chainId = Number(chainIdStr);
        const type = config.type as LayerType;

        // Check for duplicates
        if (Object.prototype.hasOwnProperty.call(chainConfig, chainId)) {
          logger.error(`Duplicate chainId ${chainId} found in configuredChains.json`);
          throw new Error();
        }

        // Validate LayerType
        if (!Object.values(LayerType).includes(config.type)) {
          logger.error(`Invalid LayerType ${config.type} found for chainId ${chainId}`);
          throw new Error();
        }

        chainConfig[chainId] = { ...config, type };
      }
    });
  }

  // Add chainConfig variable to sourceFile
  sourceFile.addVariableStatement({
    declarationKind: VariableDeclarationKind.Const,
    declarations: [
      {
        name: 'chainConfig',
        type: 'ChainConfigMap',
        initializer: _formatObjectToTsLiteral(chainConfig),
      },
    ],
    isExported: true,
  });

  if (skip) {
    logger.info(`Skipped chains.`);
  } else {
    logger.info(`Configured ${Object.keys(chainConfig).length} chains.`);
  }
  return sourceFile;
}

enum LayerType {
  L1 = 'L1',
  L2 = 'L2',
  L3 = 'L3',
}

const _formatObjectToTsLiteral = (obj: ChainConfigMap): string => {
  const formatValue = (value: ChainConfig): string => {
    if (typeof value === 'string') {
      if (Object.values(LayerType).includes(value as LayerType)) {
        return `LayerType.${value}`; // This line is using LayerType as an enum, but it is now a type
      }
      return `"${value}"`;
    }
    if (typeof value === 'number' || typeof value === 'boolean' || value === null) {
      return String(value);
    }
    if (Array.isArray(value)) {
      return `[${value.map(formatValue).join(', ')}]`;
    }
    if (typeof value === 'object') {
      return _formatObjectToTsLiteral(value);
    }
    return 'undefined';
  };

  if (Array.isArray(obj)) {
    return `[${obj.map(formatValue).join(', ')}]`;
  }

  const entries = Object.entries(obj);
  const formattedEntries = entries.map(([key, value]) => `${key}: ${formatValue(value)}`);

  return `{${formattedEntries.join(', ')}}`;
};
