import React, { useState, useCallback } from 'react';
import { hederaService, MintPayload, BurnPayload, AgriToken, WarehouseReceiptPayload, CreateTokenPayload, WarehouseReceipt } from '../services/hederaService';
import { useNotificationHelpers } from '../hooks/useNotificationHelpers';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import Modal from '../components/Modal';
import ModalForm from '../components/ModalForm';
import { getAllUsers } from '../services/userService';
import { getAllProducts } from '../services/productService';
import { User } from '../components/UserForm';
import { Product } from '../services/productService';

type FormType = 'createWarehouseReceipt' | 'createToken' | 'mint' | 'burn' | null;

const HederaManagement: React.FC = () => {
  const { showSuccess, showError } = useNotificationHelpers();
  const queryClient = useQueryClient();

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentFormType, setCurrentFormType] = useState<FormType>(null);
  const [selectedToken, setSelectedToken] = useState<AgriToken | null>(null);

  const [warehouseReceiptData, setWarehouseReceiptData] = useState({ farmerId: '', productId: '', batchNumber: '', grossWeight: '', netWeight: '', weightUnit: 'KG', storageLocation: '', qualityGrade: '' });
  const [createTokenData, setCreateTokenData] = useState({ tokenName: '', tokenSymbol: '', maxSupply: '', treasuryAccountId: '', warehouseReceiptId: '' });
  const [mintData, setMintData] = useState({ tokenId: '', amount: '' });
  const [burnData, setBurnData] = useState({ tokenId: '', accountId: '', amount: '' });

  const { data: users } = useQuery<User[]>({ queryKey: ['users'], queryFn: getAllUsers });
  const { data: products } = useQuery<Product[]>({ queryKey: ['products'], queryFn: getAllProducts });
  const { data: warehouseReceipts } = useQuery<WarehouseReceipt[]>({ queryKey: ['warehouseReceipts'], queryFn: hederaService.listWarehouseReceipts });

  const farmers = users?.filter(user => user.role === 'FARMER');

  const handleInputChange = useCallback(<T,>(setter: React.Dispatch<React.SetStateAction<T>>) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setter(prev => ({ ...prev, [name]: value }));
  }, []);

  const handleSubmit = async (action: (data: any) => Promise<any>, data: any, successMessage: string) => {
    try {
      await action(data);
      showSuccess(successMessage);
      queryClient.invalidateQueries({ queryKey: ['agriTokens'] });
      setIsModalOpen(false);
      setCurrentFormType(null);
    } catch (error) {
      showError('Une erreur est survenue.', error);
    }
  };

  const openModal = (formType: FormType, token?: AgriToken) => {
    setCurrentFormType(formType);
    setSelectedToken(token || null);
    setIsModalOpen(true);

    // Reset form data when opening modal for a new form type
    if (formType === 'createWarehouseReceipt') setWarehouseReceiptData({ farmerId: '', productId: '', batchNumber: '', grossWeight: '', netWeight: '', weightUnit: 'KG', storageLocation: '', qualityGrade: '' });
    if (formType === 'createToken') setCreateTokenData({ tokenName: '', tokenSymbol: '', maxSupply: '', treasuryAccountId: '', warehouseReceiptId: '' });
    if (formType === 'mint' && token) setMintData({ tokenId: token.hederaTokenId, amount: '' });
    if (formType === 'burn' && token) setBurnData({ tokenId: token.hederaTokenId, accountId: '', amount: '' });
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setCurrentFormType(null);
    setSelectedToken(null);
  };

  const { data: agriTokens, isLoading, isError, error } = useQuery<AgriToken[]>({ 
    queryKey: ['agriTokens'], 
    queryFn: hederaService.listTokens 
  });

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-6">Gestion des Opérations Hedera</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <button onClick={() => openModal('createWarehouseReceipt')} className="w-full bg-purple-500 text-white py-2 rounded-md">Créer un Reçu d'Entrepôt</button>
        <button onClick={() => openModal('createToken')} className="w-full bg-teal-500 text-white py-2 rounded-md">Créer un AgriToken</button>
      </div>

      <Modal isOpen={isModalOpen} onClose={closeModal} title={
        currentFormType === 'createWarehouseReceipt' ? 'Créer un Reçu d\'Entrepôt' :
        currentFormType === 'createToken' ? 'Créer un AgriToken' :
        currentFormType === 'mint' ? 'Minter des AgriTokens' :
        currentFormType === 'burn' ? 'Brûler des AgriTokens' :
        ''
      }> 
        {currentFormType === 'createWarehouseReceipt' && (
          <ModalForm
            onSubmit={(e) => { 
              e.preventDefault(); 
              const payload: WarehouseReceiptPayload = { 
                ...warehouseReceiptData, 
                farmerId: parseFloat(warehouseReceiptData.farmerId), 
                productId: parseFloat(warehouseReceiptData.productId), 
                grossWeight: parseFloat(warehouseReceiptData.grossWeight), 
                netWeight: parseFloat(warehouseReceiptData.netWeight) 
              };
              handleSubmit(() => hederaService.createWarehouseReceipt(payload), 'Reçu d\'entrepôt créé avec succès!'); 
            }}
            onCancel={closeModal}
          >
            <select name="farmerId" value={warehouseReceiptData.farmerId} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded">
              <option value="">Sélectionnez un agriculteur</option>
              {farmers?.map(farmer => <option key={farmer.id} value={farmer.id}>{farmer.firstName} {farmer.lastName}</option>)}
            </select>
            <select name="productId" value={warehouseReceiptData.productId} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded">
              <option value="">Sélectionnez un produit</option>
              {products?.map(product => <option key={product.id} value={product.id}>{product.name}</option>)}
            </select>
            <input name="batchNumber" type="text" placeholder="Numéro de lot" value={warehouseReceiptData.batchNumber} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
            <input name="grossWeight" type="number" placeholder="Poids brut" value={warehouseReceiptData.grossWeight} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
            <input name="netWeight" type="number" placeholder="Poids net" value={warehouseReceiptData.netWeight} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
            <input name="weightUnit" type="text" placeholder="Unité de poids" value={warehouseReceiptData.weightUnit} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
            <input name="storageLocation" type="text" placeholder="Lieu de stockage" value={warehouseReceiptData.storageLocation} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
            <input name="qualityGrade" type="text" placeholder="Qualité" value={warehouseReceiptData.qualityGrade} onChange={handleInputChange(setWarehouseReceiptData)} className="w-full p-2 border rounded" />
          </ModalForm>
        )}

        {currentFormType === 'createToken' && (
          <ModalForm
            onSubmit={(e) => { 
              e.preventDefault(); 
              const payload: CreateTokenPayload = { 
                ...createTokenData, 
                maxSupply: parseFloat(createTokenData.maxSupply), 
                warehouseReceiptId: parseFloat(createTokenData.warehouseReceiptId) 
              };
              handleSubmit(() => hederaService.createToken(payload), 'AgriToken créé avec succès!'); 
            }}
            onCancel={closeModal}
          >
            <input name="tokenName" type="text" placeholder="Nom du token" value={createTokenData.tokenName} onChange={handleInputChange(setCreateTokenData)} className="w-full p-2 border rounded" />
            <input name="tokenSymbol" type="text" placeholder="Symbole du token" value={createTokenData.tokenSymbol} onChange={handleInputChange(setCreateTokenData)} className="w-full p-2 border rounded" />
            <input name="maxSupply" type="number" placeholder="Offre maximale" value={createTokenData.maxSupply} onChange={handleInputChange(setCreateTokenData)} className="w-full p-2 border rounded" />
            <input name="treasuryAccountId" type="text" placeholder="ID du compte de trésorerie" value={createTokenData.treasuryAccountId} onChange={handleInputChange(setCreateTokenData)} className="w-full p-2 border rounded" />
            <select name="warehouseReceiptId" value={createTokenData.warehouseReceiptId} onChange={handleInputChange(setCreateTokenData)} className="w-full p-2 border rounded">
              <option value="">Sélectionnez un reçu d'entrepôt</option>
              {warehouseReceipts?.map(receipt => <option key={receipt.id} value={receipt.id}>{receipt.batchNumber}</option>)}
            </select>
          </ModalForm>
        )}

        {currentFormType === 'mint' && selectedToken && (
          <ModalForm
            onSubmit={(e) => { 
              e.preventDefault(); 
              const payload: MintPayload = { ...mintData, amount: parseFloat(mintData.amount) };
              handleSubmit(() => hederaService.mintTokens(payload), 'Tokens mintés avec succès!'); 
            }}
            onCancel={closeModal}
          >
            <input name="tokenId" type="hidden" value={mintData.tokenId} />
            <p>Token ID: {selectedToken.hederaTokenId}</p>
            <input name="amount" type="number" placeholder="Quantité à minter" value={mintData.amount} onChange={handleInputChange(setMintData)} className="w-full p-2 border rounded" />
          </ModalForm>
        )}

        {currentFormType === 'burn' && selectedToken && (
          <ModalForm
            onSubmit={(e) => { 
              e.preventDefault(); 
              const payload: BurnPayload = { ...burnData, amount: parseFloat(burnData.amount) };
              handleSubmit(() => hederaService.burnTokens(payload), 'Tokens brûlés avec succès!'); 
            }}
            onCancel={closeModal}
          >
            <input name="tokenId" type="hidden" value={burnData.tokenId} />
            <p>Token ID: {selectedToken.hederaTokenId}</p>
            <input name="accountId" type="text" placeholder="ID du compte de l\'acheteur" value={burnData.accountId} onChange={handleInputChange(setBurnData)} className="w-full p-2 border rounded" />
            <input name="amount" type="number" placeholder="Quantité à brûler" value={burnData.amount} onChange={handleInputChange(setBurnData)} className="w-full p-2 border rounded" />
          </ModalForm>
        )}
      </Modal>

      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-xl font-semibold mb-4">Liste des AgriTokens</h2>
        {isLoading && <p>Chargement des tokens...</p>}
        {isError && <p className="text-red-500">Erreur lors du chargement des tokens: {error?.message}</p>}
        {agriTokens && agriTokens.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hedera Token ID</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nom</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Symbole</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Max Supply</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Minted Amount</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Treasury Account ID</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agriculteur</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Active</th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {agriTokens.map((token) => (
                  <tr key={token.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{token.id}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.hederaTokenId}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.tokenName}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.tokenSymbol}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.maxSupply}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.mintedAmount}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.treasuryAccountId}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{`${token.warehouseReceiptFarmerFirstName} ${token.warehouseReceiptFarmerLastName}`}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{token.active ? 'Oui' : 'Non'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button onClick={() => openModal('mint', token)} className="text-indigo-600 hover:text-indigo-900 mr-4">Minter</button>
                      <button onClick={() => openModal('burn', token)} className="text-red-600 hover:text-red-900">Brûler</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          !isLoading && !isError && <p>Aucun AgriToken trouvé.</p>
        )}
      </div>
    </div>
  );
};

export default HederaManagement;