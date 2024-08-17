# BEI Stable Coin

This is a rewrite of the Maker stablecoin DEI, drawing from insights on smart contract development from the [YouTube playlist](https://www.youtube.com/playlist?list=PLO5VPQH6OWdW9b6GKJR4Dt9XZxQlJuVp_).

```shell
forge build
forge test
```


### Links

- [docs](https://docs.makerdao.com/)
- [dss](https://github.com/makerdao/dss)
- [dss-proxy](https://github.com/makerdao/dss-proxy)
- [dss-proxy-actions](https://github.com/makerdao/dss-proxy-actions)
- [dss-cdp-manager](https://github.com/makerdao/dss-cdp-manager)
- [osm](https://github.com/makerdao/osm)


```
par [ray] 1000000000000000000000000000
mat [ray] 1450000000000000000000000000
val [wad] 2067300000000000000000
spot [ray] 1429862068965517241379310344827

liquidation ratio = mat / par
                  = collateral USD value / debt USD value

liquidation price = spot = val * 1e9 * par / mat
```