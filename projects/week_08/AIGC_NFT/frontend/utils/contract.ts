import { ethers } from 'ethers';

export const CONTRACT_ADDRESS = '0xed6ae8ceec65c9aab767e68de9dc9d59a85863ae' //'0x2FFAC0DC7CFF9361dD4Ce2549168d7ac69448eE3'

export const CONTRACT_ABI = [
  'function estimateTotalFee() view returns (uint256)',
  'function requestMint(string prompt) payable',
  'function tokenCounter() view returns (uint256)',
  'function tokenURI(uint256 tokenId) view returns (string)',
];

export function getContract(signerOrProvider: ethers.Signer | ethers.providers.Provider) {
  return new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signerOrProvider);
}
