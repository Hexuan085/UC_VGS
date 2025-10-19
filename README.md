# Vertex-Guided Redundant Constraints Identification for Unit Commitment (UC_VGS)

This repository contains the code and resources related to the research paper "Vertex-Guided Redundant Constraints Identification for Unit Commitment". This work proposes a novel approach to accelerate the Unit Commitment (UC) problem by efficiently identifying and eliminating redundant constraints in power system models.

## Abstract

The Unit Commitment (UC) problem is critical for reliable and economic power system operation, but its timely solution is challenged by the increasing penetration of stochastic renewables and dynamic demand behaviors. Traditional constraint screening methods, often based on Linear Programming (LP), are computationally intensive due as they require solving numerous LPs. This paper introduces a novel vertex-guided perspective on LP-based screening. Our key insight is that redundant constraints are satisfied by all vertices of the screened feasible region. By tightening the bounds of UC decision variables through fewer LPs, we construct an outer approximation (a hyperrectangle) of the UC feasible region. A matrix operation is then applied to the vertices of this outer approximation to identify redundant constraints efficiently. Further adjustments, including considering load operating ranges and cutting planes derived from UC cost and discrete unit status predictions, are explored to enhance screening efficiency. Extensive simulations on testbeds up to 2,383 buses demonstrate that our proposed schemes achieve up to 8.8x acceleration compared to classic LP-based screening while identifying the same redundant constraints.

## Key Contributions

1.  **Novel Vertex-Guided Perspective**: Proposed a vertex-guided approach for LP-based constraint screening, where the computational cost depends on the number of decision variables rather than constraints, leading to significantly faster screening for UC problems.
2.  **Ensemble Screening Strategy (EOVL)**: Introduced an ensemble method combining Vertex-Guided Screening (VGS) and Line Flow-Guided Screening (LFGS) to ensure sufficient constraint elimination while maintaining high speed.
3.  **Enhanced Applicability and Efficiency**:
    *   Integrated load operating ranges to provide applicability across varying load inputs.
    *   Incorporated predictions of UC cost and on/off commitment as cutting planes to further tighten the screened region and remove more constraints.
4.  **Machine Learning Integration**: Utilized Neural Network (NN) and K-Nearest-Neighbor (KNN) models as discrete variable predictors to improve the method's effectiveness.
5.  **Extensive Validation**: Performed comprehensive case studies on systems up to 2,383 buses, validating the proposed methods' effectiveness with up to 8.8x acceleration compared to LFGS.

## Method Overview

The core of this work is the **Vertex-Guided Screening (VGS)** method. Instead of optimizing each line flow (as in traditional LFGS), VGS focuses on the actual bounds of UC decision variables.

1.  **Outer Approximation**: By relaxing binary variables in the UC model to continuous variables, an LP is solved to obtain the upper and lower bounds for each UC decision variable. These bounds are then used to construct a hyperrectangle, which serves as an outer approximation of the UC feasible region.
2.  **Fast Identification**: A novel matrix operation is designed to efficiently check if constraints are redundant by evaluating them against the variables' bounds, avoiding cumbersome vertex-by-vertex checks.
3.  **Ensemble Strategy (EOVL)**: To balance screening speed and sufficiency, VGS is first applied to remove most redundant constraints, followed by LFGS for the remaining constraints.
4.  **Improvements**:
    *   **Load Operating Range**: The method is extended to identify mutual redundant constraints across a predefined load operating range, making the reduced model applicable for varying load inputs.
    *   **Cost Cut**: A cutting plane based on predicted UC costs (using a trained Neural Network) is integrated to tighten the screened region.
    *   **Commitment Cut**: Predicted Commitment (on/off statuses) for partial units (using KNN) are incorporated as additional constraints to further restrict the bounds and remove more constraints.

## Experimental Results

The proposed methods were evaluated on IEEE 39-, 118-, 300-, 500-, and 2383-bus power systems.

*   **Acceleration**: VGS achieved up to 12.21x faster screening compared to LFGS for the 2383-bus system. The EOVL ensemble method achieved up to 8.81x acceleration for the 500-bus system while identifying the same number of redundant constraints as LFGS.
*   **Computational Cost-Effectiveness**: VGS and EOVL demonstrated higher cost-effectiveness (ratio of removed limits to LPs solved), with improvements up to 9.46x compared to LFGS.
*   **UC Solution Time Reduction**: Removing redundant line limits reduced the average UC solution time from 12.44% to 80.21% without introducing a solution gap.
*   **Load Operating Range**: The reduced models for a given load operating range produced identical solutions for all tested instances, accelerating the solution process by an average factor of 1.91x to 7.24x.
*   **Cost and Commitment Cuts**: Integrating cost cuts and commitment cuts further enhanced screening performance, reducing screening times by over 10% in all cases (up to 47.07% for the 2383-bus system) and increasing the number of removed constraints.

## Installation and Usage

The simulations were carried out on an unloaded MacBook Air with Apple M1 and 8G RAM. All optimization problems were modeled and solved using the **YALMIP toolbox** and **MPT3 toolbox** in **MATLAB R2022b**.

To run the simulations, you will need:
*   MATLAB R2022b or later.
*   YALMIP toolbox.
*   MPT3 toolbox.
*   TensorFlow (for Neural Network models, likely integrated with MATLAB or Python).

The repository structure suggests the following components:
*   `Data/`: Contains system configurations (e.g., `case_ACTIVSg500.m`, `GEN*.csv`, `PTDF*.csv`, `load*.csv`, `parameters_*.m`).
*   `adjusted_toolbox/`: Modified MPT3 functions (`minHRep_GE.m`, `mpt_mplp_26_GE.m`, `outerApprox_GE.m`, `validate_GE.m`).
*   `UC_Cost_bound/`: Scripts for cost bound prediction (`data_collection_cost.m`, `UC_GE_Cost.m`) and related data.
*   `VT_BT_Comparison/`: Scripts for VGS/LFGS comparison (`UC_GE_VT_BT.m`) and result analysis.
*   `VT_BT_Prediction/`: Scripts for unit status prediction (`data_collection_unit.m`, `mKNearestNeighbor.m`, `UC_GE_Status.m`, `Unit_prediction.m`) and related data.
*   `VT_BT_Range/`: Scripts for load operating range analysis (`UC_MPP_range.m`).
*   `Solve_UC_GE.m`, `Solve_UC_Semantic.m`, `rpOps.m`: Main MATLAB scripts for solving UC problems and related operations.

**General Steps:**
1.  Ensure MATLAB R2022b (or newer), YALMIP, and MPT3 are installed and configured.
2.  Clone this repository: `git clone https://github.com/Hexuan085/UC_VGS.git`
3.  Navigate to the cloned directory.
4.  Run the main MATLAB scripts (e.g., `Solve_UC_GE.m`, `UC_GE_VT_BT.m`) to reproduce the results. Specific instructions for running each scheme (S1-S7) would be found within the MATLAB scripts or accompanying documentation.

## Citation

If you find this work useful, please cite the corresponding paper:

```
@article{he2025vertex,
  title={Vertex-Guided Redundant Constraints Identification for Unit Commitment},
  author={He, Xuan and Pan, Yuxin and Chen, Yize and Tsang, Danny HK},
  journal={arXiv preprint arXiv:2507.09280},
  year={2025}
}
```

## Contact

For any questions or inquiries, please contact the authors listed in the paper.
