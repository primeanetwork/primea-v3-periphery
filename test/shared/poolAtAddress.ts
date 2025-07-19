import { abi as POOL_ABI } from '@primea/v3-core/artifacts/contracts/PrimeaV3Pool.sol/PrimeaV3Pool.json'
import { Contract, Wallet } from 'ethers'
import { IPrimeaV3Pool } from '../../typechain'

export default function poolAtAddress(address: string, wallet: Wallet): IPrimeaV3Pool {
  return new Contract(address, POOL_ABI, wallet) as IPrimeaV3Pool
}
