import React, { useState, useCallback } from 'react';
import { hederaService, DeployVaultWithBytecodePayload } from '../services/hederaService';
import { useNotificationHelpers } from '../hooks/useNotificationHelpers';
import Modal from '../components/Modal';
import ModalForm from '../components/ModalForm';

type FormType = 'deployVault' | null;

const ParametersConfig: React.FC = () => {
  const { showSuccess, showError } = useNotificationHelpers();

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentFormType, setCurrentFormType] = useState<FormType>(null);
  const [modalTitle, setModalTitle] = useState('');

    const [deployVaultData, setDeployVaultData] = useState({
      bytecodeHex: '',
      warehouseAccountAddress: '',
      rewardTokenAddress: '',
      depositDurationSeconds: 0,
      rewardPerHbar: 0,
    });
  
    const handleInputChange = useCallback(<T extends object>(setter: React.Dispatch<React.SetStateAction<T>>) => (e: React.ChangeEvent<HTMLInputElement>) => {
      const { name, value, type } = e.target;
      setter(prev => ({ ...prev, [name]: type === 'number' ? Number(value) : value }));
    }, []);
  
    const handleSubmit = async (action: (data: any) => Promise<any>, data: any, successMessage: string) => {
      try {
        await action(data);
        showSuccess(successMessage);
        setIsModalOpen(false);
        setCurrentFormType(null);
      } catch (error) {
        showError('Une erreur est survenue.', error);
      }
    };
  
    const openModal = (formType: FormType) => {
      setCurrentFormType(formType);
      setIsModalOpen(true);
      setDeployVaultData({
        bytecodeHex: '',
        warehouseAccountAddress: '',
        rewardTokenAddress: '',
        depositDurationSeconds: 0,
        rewardPerHbar: 0,
      }); // Reset form data
    };
  
    const closeModal = () => {
      setIsModalOpen(false);
      setCurrentFormType(null);
    };
  
    return (
      <div className="container mx-auto p-4">
        <h1 className="text-2xl font-bold mb-6">Configuration des Paramètres Hedera</h1>
  
        <div className="grid grid-cols-1 gap-6 mb-8">
          <button onClick={() => openModal('deployVault')} className="w-full bg-green-500 text-white py-2 rounded-md">Déployer le HarvestVault</button>
        </div>
  
        <Modal isOpen={isModalOpen} onClose={closeModal} title={
          currentFormType === 'deployVault' ? 'Déployer le HarvestVault' :
          ''
        }>
          {currentFormType === 'deployVault' && (
            <ModalForm
              onSubmit={(e) => {
                e.preventDefault();
                const payload: DeployVaultWithBytecodePayload = { ...deployVaultData };
                handleSubmit(() => hederaService.deployVaultWithBytecode(payload), 'HarvestVault déployé avec succès!');
              }}
              onCancel={closeModal}
            >
              <input name="bytecodeHex" type="text" placeholder="Bytecode Hexadécimal" value={deployVaultData.bytecodeHex} onChange={handleInputChange(setDeployVaultData)} className="w-full p-2 border rounded mb-4" />
              <input name="warehouseAccountAddress" type="text" placeholder="Warehouse Account Address (ex: 0.0.123456)" value={deployVaultData.warehouseAccountAddress} onChange={handleInputChange(setDeployVaultData)} className="w-full p-2 border rounded mb-4" />
              <input name="rewardTokenAddress" type="text" placeholder="Reward Token Address (ex: 0.0.123456)" value={deployVaultData.rewardTokenAddress} onChange={handleInputChange(setDeployVaultData)} className="w-full p-2 border rounded mb-4" />
              <input name="depositDurationSeconds" type="number" placeholder="Deposit Duration (seconds)" value={deployVaultData.depositDurationSeconds} onChange={handleInputChange(setDeployVaultData)} className="w-full p-2 border rounded mb-4" />
              <input name="rewardPerHbar" type="number" placeholder="Reward Per Hbar" value={deployVaultData.rewardPerHbar} onChange={handleInputChange(setDeployVaultData)} className="w-full p-2 border rounded" />
            </ModalForm>
          )}
        </Modal>
      </div>
    );
  };
  
  export default ParametersConfig;