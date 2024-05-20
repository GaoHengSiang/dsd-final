# DSD_Final

## Synthesis and Test
To synthesize the design, run
```
make syn
```
Please make sure you have `.synopsys_dc.setup` under the project's root dir or under your home dir. The synthesized file will be stored under `Syn/`

To run testbench for RTL and SYN, run
```
make tb_rtl
make tb_syn
```

There are several flags that you can define, for example:
```
make tb_rtl TB_DEFINE=noHazard
```

The full list of availble flags are:

    - noHazard
    - hasHazard
    - BrPred
    - compression
    - compression_uncompressed
    - Mul
    - QSort
    - QSort_uncompressed
    - Conv
    - Conv_uncompressed