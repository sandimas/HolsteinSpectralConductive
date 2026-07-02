<!--
[![Paper](https://img.shields.io/badge/paper-arXiv%3A2201.04155-B31B1B.svg)](https://arxiv.org/)
[![DOI](https://zenodo.org/badge/396873415.svg)](https://zenodo.org/badge/latestdoi/396873415)
-->
# A DQMC study of the spectral and conductive properties of the two-dimensional Holstein model

James Neuhaus, Ben Cohen-Stead, Norman Mannella, Steve Johnston

[arXiv:2201.04155](https://arxiv.org/abs/2201.04155)

### Abstract
We study the dynamical properties of the two-dimensional square lattice Holstein Hamiltonian using numerically exact determinant quantum Monte Carlo simulations. In particular, we report systematic calculations of the model’s single-particle spectral function and optical conductivity over a range of phonon energies Ω, electron-phonon coupling strengths, carrier concentrations, and temperatures. In doing so, we map the evolution of the system from a dressed metallic phase to a (bi)polaron liquid/insulator to a charge-density-wave insulator as the carrier concentration is tuned from dilute values to half-filling. We corroborate these results using several equal-time correlation measurements and related proxy quantities reconstructed from time-displaced correlation measurements. This paper is also accompanied by an extensive open data set, covering over 16,640 unique parameter values.

### Description
This repository includes links, code, scripts, and data to generate the figures in a paper.

### Requirements
The data in this project was generated via determinant quantum Monte Carlo (QMC) and analytic continuation techniques.  Everything included in the [data](https://github.com/sandimas/HolsteinSpectralConductive/2_data) directory was generated via:

* [SmoQyDQMC.jl: A Julia implementaion of the differential evolution for analytic continuation algorithm](https://github.com/SmoQySuite/SmoQyDQMC.jl.git)
* [SmoQyDEAC.jl: A Julia implementaion of the differential evolution for analytic continuation algorithm](https://github.com/SmoQySuite/SmoQyDEAC.jl.git)
* [ana_cont: A Python implementaion of the Maximum Entropy (MaxEnt) analytic continuation method](https://github.com/josefkaufmann/ana_cont)

### Repository Structure


### Support
We thank M. Berciu and R. T. Scalettar for useful discussions and comments for this work. This work was supported by the U.S. Department of Energy, Office of Science, Office of Basic Energy Sciences, under Award No. DE-SC0022311.
<!--  -->
[<img width="400px" src="https://www.energy.gov/sites/default/files/styles/full_article_width/public/2025-02/Logo_Color_Seal_Blue_Lettering_Horizontal.png">](pamspublic.science.energy.gov/WebPAMSExternal/Interface/Common/ViewPublicAbstract.aspx?rv=31bd2b59-7a7a-424c-83cc-fad4b3df485f&rtc=24&PRoleId=10)

### Figures

#### Figure 01: 
<img src="3_paper_plots/plots_png/plot1_spec_n1.0_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 02: 
<img src="3_paper_plots/plots_png/plot2_cond_n1.0_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 03: 
<img src="3_paper_plots/plots_png/plot3_spec_n0.7_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 04: 
<img src="3_paper_plots/plots_png/plot4_cond_n0.7_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 05: 
<img src="3_paper_plots/plots_png/plot5_spec_n0.7_o2.0.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 06: 
<img src="3_paper_plots/plots_png/plot6_cond_n0.7_o2.0.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 07: 
<img src="3_paper_plots/plots_png/plot7_polaron_n0.7.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 08: 
<img src="3_paper_plots/plots_png/plot8_crossover_375_1.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 09: 
<img src="3_paper_plots/plots_png/plot9_crossover_375_4.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 10: 
<img src="3_paper_plots/plots_png/plot10_crossover_375_2.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 11: 
<img src="3_paper_plots/plots_png/plot11_crossover_375_3.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 12: 
<img src="3_paper_plots/plots_png/plot12_spec_n0.3_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 13: 
<img src="3_paper_plots/plots_png/plot13_cond_n0.3_o0.5.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 14: 
<img src="3_paper_plots/plots_png/plot14_spec_n0.3_o2.0.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 15: 
<img src="3_paper_plots/plots_png/plot15_cond_n0.3_o2.0.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 16: 
<img src="3_paper_plots/plots_png/plot16_mu_vs_n.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

#### Figure 17: 
<img src="3_paper_plots/plots_png/plotA1_finite_size.png" width="600px" style="background-color:white;padding:20px;">

This figure is released under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and can be freely copied, redistributed and remixed.

