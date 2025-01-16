package main

import (
    "fmt"
    "log"
    "math/big"
    "os"
    "path/filepath"

    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/consensus/bor"
    "github.com/ethereum/go-ethereum/core"
    "github.com/ethereum/go-ethereum/eth"
    "github.com/ethereum/go-ethereum/node"
    "github.com/ethereum/go-ethereum/params"
)

const (
    
    ChainID = 99999
   
    DataDir = "./chaindata"
)


var genesis = &core.Genesis{
    Config: &params.ChainConfig{
        ChainID:             big.NewInt(ChainID),
        HomesteadBlock:      big.NewInt(0),
        EIP150Block:         big.NewInt(0),
        EIP155Block:         big.NewInt(0),
        EIP158Block:         big.NewInt(0),
        ByzantiumBlock:      big.NewInt(0),
        ConstantinopleBlock: big.NewInt(0),
        PetersburgBlock:     big.NewInt(0),
        IstanbulBlock:       big.NewInt(0),
        Bor: &params.BorConfig{
            Period: 1,            
            ValidatorContract: common.HexToAddress("0x0000000000000000000000000000000000001000"),
        },
    },
    Timestamp:  0,
    ExtraData:  []byte{},
    GasLimit:   8000000,
    Difficulty: big.NewInt(1),
    Alloc:      core.GenesisAlloc{},
}

func main() {
    
    config := &node.Config{
        Name:    "bor-sidechain",
        Version: params.VersionWithCommit("", ""),
        DataDir: DataDir,
    }

    stack, err := node.New(config)
    if err != nil {
        log.Fatalf("Failed to create node: %v", err)
    }

    ethConfig := &eth.Config{
        Genesis: genesis,
        NetworkId: ChainID,
        SyncMode: eth.DefaultConfig.SyncMode,
        DatabaseCache: 512,
        TrieTimeout: eth.DefaultConfig.TrieTimeout,
    }

    
    borConfig := &bor.Config{
        Period: genesis.Config.Bor.Period,
        Sprint: genesis.Config.Bor.Sprint,
    }
    
    engine := bor.New(borConfig, nil)
   
    if err := stack.Register(func(ctx *node.ServiceContext) (node.Service, error) {
        return eth.New(ctx, ethConfig, engine)
    }); err != nil {
        log.Fatalf("Failed to register Ethereum protocol: %v", err)
    }

   
    if err := stack.Start(); err != nil {
        log.Fatalf("Failed to start node: %v", err)
    }
    defer stack.Close()

    
    genesisPath := filepath.Join(DataDir, "genesis.json")
    if _, err := os.Stat(genesisPath); os.IsNotExist(err) {
        if err := genesis.Write(genesisPath); err != nil {
            log.Fatalf("Failed to write genesis file: %v", err)
        }
        fmt.Println("Genesis block written to", genesisPath)
    }

    stack.Wait()
}