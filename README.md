<!--
[![Paper](https://img.shields.io/badge/paper-arXiv%3A2201.04155-B31B1B.svg)](https://arxiv.org/)
[![DOI](https://zenodo.org/badge/396873415.svg)](https://zenodo.org/badge/latestdoi/396873415)
-->
# A DQMC study of the spectral and conductive properties of the two-dimensional Holstein model

James Neuhaus, Ben Cohen-Stead, Norman Mannella, Steve Johnston

<!-- [arXiv:2201.04155](https://arxiv.org/abs/2201.04155)
-->
### Abstract
We study the dynamical properties of the two-dimensional square lattice Holstein Hamiltonian using numerically exact determinant quantum Monte Carlo simulations. In particular, we report systematic calculations of the model’s single-particle spectral function and optical conductivity over a range of phonon energies Ω, electron-phonon coupling strengths, carrier concentrations, and temperatures. In doing so, we map the evolution of the system from a dressed metallic phase to a (bi)polaron liquid/insulator to a charge-density-wave insulator as the carrier concentration is tuned from dilute values to half-filling. We corroborate these results using several equal-time correlation measurements and related proxy quantities reconstructed from time-displaced correlation measurements. This paper is also accompanied by an extensive open data set, covering over 16,640 unique parameter values.

### Description
This repository includes links, code, scripts, and data to generate the figures in a paper.

### Requirements
The data in this project was generated via determinant quantum Monte Carlo (QMC) and analytic continuation techniques.  Everything included in the [data](https://github.com/sandimas/HolsteinSpectralConductive/2_data) directory was generated via:

* [SmoQyDQMC.jl: A Julia implementaion of the differential evolution for analytic continuation algorithm](https://github.com/SmoQySuite/SmoQyDQMC.jl.git)
* [SmoQyDEAC.jl: A Julia implementaion of the differential evolution for analytic continuation algorithm](https://github.com/SmoQySuite/SmoQyDEAC.jl.git)
* [ana_cont: A Python implementaion of the Maximum Entropy (MaxEnt) analytic continuation method](https://github.com/josefkaufmann/ana_cont)


### Support
We thank M. Berciu and R. T. Scalettar for useful discussions and comments for this work. This work was supported by the U.S. Department of Energy, Office of Science, Office of Basic Energy Sciences, under Award No. DE-SC0022311.
<!-- width="200px" -->
[<img src="https://www.energy.gov/sites/default/files/styles/full_article_width/public/2025-02/Logo_Color_Seal_Blue_Lettering_Horizontal.png">](pamspublic.science.energy.gov/WebPAMSExternal/Interface/Common/ViewPublicAbstract.aspx?rv=31bd2b59-7a7a-424c-83cc-fad4b3df485f&rtc=24&PRoleId=10)

### Figures

#### Figure 01: A schematic representation of the method to determine the optimal regularization constant when using the maximum entropy approach.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/maxent_cartoon.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 02: Nine different spectral reconstructions using different analytic continuation methods on simulated quantum Monte Carlo data.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/nine_panel_small.svg" width="800px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 03: Analytic continuation results using DEAC, FESOM, and MEM for the *tso* case at *medium* error level.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/tso_medium.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 04: CPU time required to generate the final spectra using each analytic continuation technique.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/CPU_time_large.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 05: Population size scaling for the DEAC algorithm performing analytic continuation of the tsc case at large error level.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/population_scaling.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 06 (top): The phonon-roton spectrum of helium-4 at T=1.56K from neutron scattering experiments on superfluid helium.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/bulk_he_spectrum_sokol.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 06 (bottom): The phonon-roton spectrum of helium-4 at T=1.35K as generated by DEAC from canonical quantum Monte Carlo data (bottom).
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/bulk_he_spectrum.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 07: Maximum peak locations for the helium-4 dispersion at T=1.35 as generated by analytic continuation of QMC data using the DEAC algorithm.
<img src="https://github.com/DelMaestroGroup/papers-code-DEAC/blob/main/figures/helium_dispersion.svg" width="400px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.
