'use client';

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { getContract } from '@/utils/contract';
import { Sparkles } from 'lucide-react';

export default function Home() {
  const [provider, setProvider] = useState<ethers.providers.Web3Provider>();
  const [signer, setSigner] = useState<ethers.Signer>();
  const [contract, setContract] = useState<ethers.Contract>();
  const [connectedAddress, setConnectedAddress] = useState<string>('');
  const [balance, setBalance] = useState<string>('');
  const [prompt, setPrompt] = useState('');
  const [mintFee, setMintFee] = useState<string>('0');
  const [minting, setMinting] = useState(false);
  const [toast, setToast] = useState('');
  const [lastTx, setLastTx] = useState<string>('');

  const connectWallet = async () => {
    if (!window.ethereum) return alert('Please install MetaMask');
    const _provider = new ethers.providers.Web3Provider(window.ethereum);
    await _provider.send('eth_requestAccounts', []);
    const _signer = _provider.getSigner();
    const _address = await _signer.getAddress();
    const _contract = getContract(_signer);
    const _balance = await _provider.getBalance(_address);

    setProvider(_provider);
    setSigner(_signer);
    setContract(_contract);
    setConnectedAddress(_address);
    setBalance(ethers.utils.formatEther(_balance));
  };

  const fetchMintFee = async () => {
    if (!contract) return;
    const fee = await contract.estimateTotalFee();
    setMintFee(ethers.utils.formatEther(fee));
  };

  const handleMint = async () => {
    if (!contract || !signer || !prompt) return;
    try {
      setMinting(true);
      setToast('Minting in progress...');
      const fee = await contract.estimateTotalFee();
      const tx = await contract.requestMint(prompt, { value: fee });
      setLastTx(tx.hash);
      await tx.wait();
      setToast('Mint complete!');
      setPrompt('');
    } catch (err) {
      console.error(err);
      setToast('Mint failed. See console for details.');
    } finally {
      setMinting(false);
    }
  };

  useEffect(() => {
    if (contract) {
      fetchMintFee();
    }
  }, [contract]);

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-800 text-white px-6 py-10 flex items-center justify-center text-center font-sans">
      <div className="w-full max-w-2xl">
        <h1 className="text-5xl font-extrabold mb-2 tracking-tight">AI NFT Generator</h1>
        <p className="text-gray-400 mb-6 text-lg">Create and mint AI-generated NFTs from your ideas, right on-chain.</p>

        <div className="text-sm text-gray-400 mb-6">
          <div className="flex items-center justify-center gap-2">
            <Sparkles size={18} className="text-yellow-300" />
            <span><strong>Model:</strong> Stable Diffusion XL (modelId: 50)</span>
          </div>
          <p>
            Powered by{' '}
            <a
              href="https://ora.io"
              target="_blank"
              rel="noopener noreferrer"
              className="underline text-blue-400 hover:text-blue-300"
            >
              ORA Protocol ↗
            </a>{' '}
            – enabling on-chain AI inference
          </p>
        </div>

        {!connectedAddress ? (
          <button
            onClick={connectWallet}
            className="bg-blue-600 hover:bg-blue-500 transition text-white px-6 py-3 rounded-xl font-semibold shadow-md"
          >
            Connect MetaMask
          </button>
        ) : (
          <div className="space-y-4">
            <p className="text-sm text-green-400">Connected: {connectedAddress}</p>
            <p className="text-sm text-gray-300">Balance: {balance} ETH</p>
            {lastTx && (
              <p className="text-sm text-blue-400">
                Last Tx:{' '}
                <a
                  href={`https://sepolia.etherscan.io/tx/${lastTx}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="underline hover:text-blue-300"
                >
                  View on Etherscan ↗
                </a>
              </p>
            )}

            <input
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              className="w-full px-4 py-3 text-black rounded-lg bg-white placeholder-gray-500 focus:outline-none shadow-md"
              placeholder="Describe your idea..."
            />

            <button
              onClick={handleMint}
              disabled={minting}
              className={`w-full px-6 py-3 rounded-xl font-semibold text-white shadow-md transition ${
                minting ? 'bg-gray-500 cursor-not-allowed' : 'bg-green-600 hover:bg-green-500'
              }`}
            >
              {minting ? 'Minting...' : `Mint (Fee: ${mintFee} ETH)`}
            </button>

            <p className="text-sm mt-2">
              View your collection on{' '}
              <a
                href="https://testnets.opensea.io/account"
                target="_blank"
                rel="noopener noreferrer"
                className="underline text-blue-400 hover:text-blue-300"
              >
                OpenSea ↗
              </a>
            </p>
          </div>
        )}

        {toast && (
          <div className="fixed bottom-6 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-6 py-3 rounded-lg shadow-lg z-50 border border-gray-700">
            {toast}
          </div>
        )}
      </div>
    </main>
  );
}
