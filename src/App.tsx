import { ConnectButton, useCurrentAccount, useSignTransaction, useSuiClient } from '@mysten/dapp-kit'
import { Box, Button, Container, Flex, Heading } from '@radix-ui/themes'
// import { WalletStatus } from "./WalletStatus";
import { Transaction } from '@mysten/sui/transactions'

import { env } from './config'

const net = 'testnet'
const { PackageId, AotDataId, GameRecordId } = env[net]

function App() {
  const { mutateAsync: sign } = useSignTransaction()
  const client = useSuiClient()
  const account = useCurrentAccount() || undefined

  const get_register = async () => {
    if (!account) {
      console.error('请先登录！')
      return
    }
    const txb = new Transaction()
    txb.moveCall({
      package: PackageId,
      module: 'game',
      function: 'register',
      arguments: [
        txb.pure.id(AotDataId),
        txb.pure.id(GameRecordId),
      ],
    })

    // 需要设置Gas费用，否则会返回错误
    txb.setGasBudgetIfNotSet(5000000)

    sign({
      transaction: txb,
      chain: 'sui:testnet',
      account,
    }).then((res) => {
      const { bytes, signature } = res
      return client.executeTransactionBlock({
        transactionBlock: bytes,
        signature,
        options: {
          showEvents: true,
          showObjectChanges: true,
        },
      })
    }).then((_) => {
      // console.log(res)
    }).catch((_) => {
      // console.log(err)
    })
  }
  return (
    <>
      <Flex
        position="sticky"
        px="4"
        py="2"
        justify="between"
        style={{
          borderBottom: '1px solid var(--gray-a2)',
        }}
      >
        <Box>
          <Heading>dApp Starter Template</Heading>
        </Box>

        <Box>
          <ConnectButton />
        </Box>
      </Flex>
      <Container>
        <Container
          mt="5"
          pt="2"
          px="4"
          style={{ background: 'var(--gray-a2)', minHeight: 500 }}
        >
          {/* <WalletStatus /> */}
          <Button onClick={() => get_register()}>
            点我试试
          </Button>
        </Container>
      </Container>
    </>
  )
}

export default App
