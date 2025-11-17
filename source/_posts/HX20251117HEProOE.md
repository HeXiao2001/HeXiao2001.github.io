---
title: >-
  HEProOE: A Hyperedge Enhanced Probabilistic Optimal Estimation Method for
  Detecting Spatial Fuzzy Communities
tags:
  - Spatial Analysis
  - Community Detection
  - Hypergraph
  - Urban Computing
categories:
  - Research
  - Technique
description: >-
  Introducing HEProOE, an extension of the ProOE model that integrates
  hyperedges to ensure semantic consistency in spatial community detection.
cover: Figure1.png
abbrlink: 37179
date: 2025-11-17 18:00:00
---

Building upon our previous work with ProOE, we are thrilled to introduce the **Hyperedge-Enhanced Probabilistic Optimal Estimation (HEProOE)** method. This advanced model addresses a key limitation in mobility-based community detection: the fragmentation of large, semantically consistent areas. HEProOE integrates hyperedges to represent these "Indivisible Regions" (IRs), ensuring that the detected communities are not only structurally sound but also functionally coherent.

- **Paper:** The full manuscript is currently in production.
- **GitHub Repository:** The data and code can be requested from the corresponding author or the first author.

---

### **Abstract**

Identifying spatial communities with human mobility data has emerged as a key approach to understanding urban spatial structure. However, relying solely on human mobility data to partition spatial communities ignores the semantic information and may fragment large, semantic consistent Indivisible Regions (IRs) such as college campuses. Furthermore, individual spatial units often belong simultaneously to multiple IRs, creating membership uncertainty, while the spatial stochasticity of human movements inherently introduces ambiguity to the boundaries of spatial fuzzy communities. To address these challenges, we proposed the Hyperedge-Enhanced Probabilistic Optimal Estimation method (HEProOE) that integrated the hyperedge into spatial fuzzy community detection, representing IRs as semantic consistent regions. First, IRs were represented as hyperedges, where each spatial unit holds a probabilistic community membership. Second, a novel distance-weighted Jensen-Shannon (JS) divergence metric was introduced to measure the semantic consistency within each hyperedge. Finally, this metric was converted into a new likelihood component and seamlessly integrated with the mobility-based ProOE model, yielding a unified framework that simultaneously optimizes for both mobility patterns and semantic consistency. Experimental results demonstrated that HEProOE uncovers spatial fuzzy communities with significantly higher semantic consistency, providing an effective tool for a more authentic understanding of urban spatial structures.

---

### **The Challenge: Beyond Mobility Patterns**

While models like ProOE excel at identifying fuzzy communities from mobility data, they can sometimes break apart functionally unified areas—like a large university campus or a financial district—because the internal mobility patterns might not be perfectly uniform. These **Indivisible Regions (IRs)** have a strong semantic identity that should be preserved.

### **The HEProOE Framework: Integrating Semantics with Hyperedges**

HEProOE solves this by introducing **hyperedges**. In network science, a regular edge connects two nodes. A hyperedge can connect *multiple* nodes at once. We use hyperedges to model IRs, grouping all spatial units within a single functional zone (e.g., all the zones that make up "Midtown").

This creates a unified probabilistic framework that balances two goals:
1.  Aligning with observed **mobility patterns** (the strength of ProOE).
2.  Enforcing **semantic consistency** within known IRs (the new enhancement).

The overall methodology is illustrated below.

![Figure 1. Illustration of the proposed Hyperedge-Enhanced Probabilistic Optimal Estimation method. The pie chart shows the spatial units' membership to different communities. The colors represent different communities.](Figure1.png)


---

### **Study Area and Data**

We again use **New York City** as our study area. The IRs (hyperedges) were sourced from OpenStreetMap, selecting 18 prominent, named regions like "Upper West Side" and "Lenox Hill." The mobility data comes from over 8 million taxi trips.

![Figure 2. Overview of study area and data. (a) Overview of the research area. (b) Trip data for New York City. (c) IRs obtained from OpenStreetMap [Data © OpenStreetMap contributors; licensed under ODbL 1.0; openstreetmap.org/copyright].](Figure2.png)


---

### **Key Results: Semantically Consistent Communities**

The integration of hyperedges leads to a significant improvement in the quality and interpretability of the detected communities.
![Figure 3. Detection result based on HEProOE. (a) Spatial fuzzy community. (b) Confidence Index (ConI). (c) Certainty Index (CerI).](Figure3.png)

#### **Visual Comparison: ProOE vs. HEProOE**

The figure below shows a direct comparison between the communities detected by the original ProOE and the new HEProOE. While ProOE identifies a reasonable structure, it incorrectly splits the well-defined "Upper West Side" and "Upper East Side" regions. HEProOE, guided by the semantic hyperedges, correctly preserves the integrity of these large functional zones.
![Figure 4. Comparison between community detection results from (a) HEProOE, (b) ProOE, and (c) Hypergraph-MT](Figure4.png)



#### **Quantitative Evaluation**

To provide a quantitative basis for our comparison, we measured the alignment between each model's community partitions and the predefined Identified Regions (IRs) using Fuzzy Normalized Mutual Information (FNMI)30. The results are telling: HEProOE achieved the highest FNMI score (0.440), surpassing both ProOE (0.410) and Hypergraph-MT (0.312). This score confirms that our model's partitions correspond most closely to the city's established semantic geography, a finding corroborated by visual analysis.



By combining the strengths of probabilistic modeling with the structural integrity of hypergraphs, HEProOE provides a powerful and more authentic tool for understanding the complex fabric of our cities.
