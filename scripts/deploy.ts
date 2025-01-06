import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


export default buildModule("SXPriceOracle", (m) => {

    const SXPriceOracle = m.contract("SXPriceOracle")

    return { SXPriceOracle };
});
