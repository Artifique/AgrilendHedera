import apiClient from './api';

// Interfaces pour les payloads
export interface MintPayload {
  tokenId: string;
  amount: number;
}

export interface PayFarmerPayload {
  vaultContractId: string;
  farmerAccountId: string;
  amount: number;
}

export interface BurnPayload {
  tokenId: string;
  accountId: string;
  amount: number;
}

export interface CreateTokenPayload {
  tokenName: string;
  tokenSymbol: string;
  maxSupply: number;
  treasuryAccountId: string;
  warehouseReceiptId: number;
}

export interface DeployVaultWithTokenPayload {
  tokenId: string;
  amount: number;
}

export interface DeployVaultWithBytecodePayload {
  bytecodeHex: string;
  warehouseAccountAddress: string;
  rewardTokenAddress: string;
  depositDurationSeconds: number;
  rewardPerHbar: number;
}

export interface WarehouseReceiptPayload {
  farmerId: number;
  productId: number;
  batchNumber: string;
  grossWeight: number;
  netWeight: number;
  weightUnit: string;
  storageLocation: string;
  qualityGrade: string;
}

export interface WarehouseReceipt {
  id: number;
  farmerId: number;
  productId: number;
  batchNumber: string;
  grossWeight: number;
  netWeight: number;
  weightUnit: string;
  storageLocation: string;
  qualityGrade: string;
  createdAt: string;
  updatedAt: string;
}

export interface AgriToken {
  id: number;
  hederaTokenId: string;
  tokenName: string;
  tokenSymbol: string;
  totalSupply: number;
  maxSupply: number;
  mintedAmount: number;
  treasuryAccountId: string;
  metadata: string | null;
  createdAt: string;
  updatedAt: string;
  warehouseReceiptId: number;
  warehouseReceiptBatchNumber: string;
  warehouseReceiptNetWeight: number;
  warehouseReceiptWeightUnit: string;
  warehouseReceiptQualityGrade: string;
  warehouseReceiptFarmerFirstName: string;
  warehouseReceiptFarmerLastName: string;
  active: boolean;
}

// Fonctions du service
export const hederaService = {
  createWarehouseReceipt: (payload: WarehouseReceiptPayload) => {
    return apiClient.post('/admin/warehouse-receipts', payload);
  },

  listWarehouseReceipts: async () => {
    const response = await apiClient.get<{ success: boolean; message: string; data: WarehouseReceipt[]; timestamp: string }>('/admin/warehouse-receipts');
    return response.data.data;
  },

  mintTokens: (payload: MintPayload) => {
    return apiClient.post('/admin/hedera/harvest/mint', payload);
  },

  payFarmer: (payload: PayFarmerPayload) => {
    return apiClient.post('/admin/hedera/harvest/pay-farmer', payload);
  },

  burnTokens: (payload: BurnPayload) => {
    return apiClient.post('/admin/hedera/redeem/burn', payload);
  },

  createToken: (payload: CreateTokenPayload) => {
    return apiClient.post('/admin/hedera/token/create', payload);
  },

  deployVaultWithToken: (payload: DeployVaultWithTokenPayload) => {
    return apiClient.post('/admin/hedera/vault/deploy', payload);
  },

  deployVaultWithBytecode: (payload: DeployVaultWithBytecodePayload) => {
    return apiClient.post('/admin/hedera/vault/deploy', payload);
  },

  listTokens: async () => {
    const response = await apiClient.get<{ success: boolean; message: string; data: AgriToken[]; timestamp: string }>('/admin/hedera/tokens');
    return response.data.data;
  },
};
