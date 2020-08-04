---
title: No one-size-fits-all solution to clean GBIF
preprint: false
author: 
  - name: Alexander Zizka
    affiliation: 1,2
    corresponding: true
    email: alexander.zizka@idiv.de
  - name: Fernanda Antunes Carvalho
    affiliation: 3
  - name: Alice Calvente
    affiliation: 4
  - name: Mabel Rocio Baez-Lizarazo
    affiliation: 5
  - name: Andressa Cabral
    affiliation: 6    
  - name: Jéssica Fernanda Ramos Coelho
    affiliation: 4    
  - name: Matheus Colli-Silva
    affiliation: 6    
  - name: Mariana Ramos Fantinati
    affiliation: 4
  - name: Moabe Ferreira Fernandes
    affiliation: 7   
  - name: Thais Ferreira-Araújo
    affiliation: 4        
  - name: Fernanda Gondim Lambert Moreira
    affiliation: 4            
  - name: Nathália Michelly da Cunha Santos
    affiliation: 4
  - name: Tiago Andrade Borges Santos
    affiliation: 7
  - name: Renata Clicia dos Santos‐Costa
    affiliation: 4                                    
  - name: Filipe Cabreirinha Serrano
    affiliation: 8
  - name: Ana Paula Alves da Silva
    affiliation: 4    
  - name: Arthur de Souza Soares
    affiliation: 4                                            
  - name: Paolla Gabryelle Cavalcante de Souza
    affiliation: 4                            
  - name: Eduardo Calisto Tomaz
    affiliation: 4
  - name: Valéria Fonseca Vale
    affiliation: 4
  - name: Tiago Luiz Vieira
    affiliation: 7
  - name: Alexandre Antonelli
    affiliation: 9,10,11
affiliation:
  - code: 1
    address: sDiv, German Center for Integrative Biodiversity Research Halle-Jena-Leipzig (iDiv), Leipzig, Germany
  - code: 2
    address: Naturalis Biodiversity Center, Leiden, The Netherlands
  - code: 3
    address: Departamento de Genética, Ecologia e Evolução, Universidade Federal de Minas Gerais, Belo Horizonte, Brazil
  - code: 4
    address: Departamento de Botânica e Zoologia, Universidade Federal do Rio Grande do Norte, Natal, Brazil
  - code: 5
    address: Departamento de Botânica, Universidade Federal do Rio Grande do Sul, Porto Alegre, Brazil
  - code: 6
    address: Departamento de Botânica, Universidade de São Paulo, São Paulo, Brazil
  - code: 7
    address: Departamento de Ciências Biológicas, Universidade Estadual de Feira de Santana, Feira de Santana, Brazil
  - code: 8
    address: Departamento de Ecologia, Universidade de São Paulo, São Paulo, Brazil
  - code: 9
    address: Gothenburg Global Biodiversity Centre, University of Gothenburg, Gothenburg, Sweden
  - code: 10
    address: Department for Biological and Environmental Sciences, University of Gothenburg, Gothenburg, Sweden
  - code: 11
    address: Royal Botanic Gardens Kew, Richmond, United Kingdom
abstract: >
  Species occurrence records provide the basis for many biodiversity studies. They derive from georeferenced specimens deposited in natural history collections and visual observations, such as those obtained through various mobile applications. Given the rapid increase in availability of such data, the control of quality and accuracy constitutes a particular concern. Automatic filtering is a scalable and reproducible means to identify potentially problematic records and tailor datasets from public databases such as the Global Biodiversity Information Facility (GBIF; www.gbif.org), for biodiversity analyses. However, it is unclear how much data may be lost by filtering, whether the same filters should be applied across all taxonomic groups, and what the effect of filtering is on common downstream analyses. Here, we evaluate the effect of 13 recently proposed filters on the inference of species richness patterns and automated conservation assessments for 18 Neotropical taxa, including terrestrial and marine animals, fungi, and plants downloaded from GBIF. We find that a total of 44.3% of the records are potentially problematic, with large variation across taxonomic groups (25 - 90%). A small fraction of records was identified as erroneous in the strict sense (4.2%), and a much larger proportion as unfit for most downstream analyses (41.7%). Filters of duplicated information, collection year, and basis of record, as well as coordinates in urban areas, or for terrestrial taxa in the sea or marine taxa on land, have the greatest effect. Automated filtering can help in identifying problematic records, but requires customization of which tests and thresholds should be applied to the taxonomic group and geographic area under focus. Our results stress the importance of thorough recording and exploration of the meta-data associated with species records for biodiversity research.
bibliography: course_natal.bib
output:
  bookdown::pdf_book:
    base_format: rticles::peerj_article # for using bookdown features like \@ref()
    keep_tex: true
  rticles::peerj_article: default
header-includes:
  - \usepackage[export]{adjustbox}
  - \usepackage{float}
  - \floatplacement{figure}{H} 
nocite: |
    @GBIForg2019; @GBIForg2019a; @GBIForg2019b; @GBIForg2019c; @GBIForg2019d; @GBIForg2019e; @GBIForg2019f; @GBIForg2019g; @GBIForg2019h; @GBIForg2019i; @GBIForg2019j; @GBIForg2019k; @GBIForg2019l; @GBIForg2019m; @GBIForg2019n; @GBIForg2019o;@GBIForg2019p;@GBIForg2020, @GBIForg2020a, Goldblatt2008
---








# Introduction {-}
Publicly available species distribution data have become a crucial resource in biodiversity research, including studies in ecology, biogeography, systematics and conservation biology. In particular, the availability of digitized collections from museums and herbaria and citizen science observations has increased drastically over the last few years. As of today, the largest public aggregator for geo-referenced species occurrences data, the Global Biodiversity Information Facility (www.gbif.org), provides access to more than 1.5 billion geo-referenced occurrence records for species from across the globe and the tree of life. 

A central challenge to the use of these publicly available species occurrence data in research is problematic geographic coordinates, which are either erroneous or unfit for downstream analyses [for instance because they are overly imprecise, @Anderson2016]. Problems mostly arise because data aggregators such as GBIF integrate records collected with different methodologies in different places at different times---often without centralized curation and only rudimentary meta-data. For instance, problematic coordinates caused by data-entry errors or automated geo-referencing from vague locality descriptions are common [@Maldonado2015; @Yesson2007] and cause recurrent problems such as records of terrestrial species in the sea, records with coordinates assigned to the centroids of political entities, or records of species in cultivation or captivity [@Zizka2019].

Manual data cleaning based on expert knowledge can detect these issues, but it is only feasible on small taxonomic or geographic scales, and it is time-consuming and difficult to reproduce. As an alternative, automated filtering methods to identify potentially problematic records have been proposed as a scalable option, as they are able to deal with datasets containing up to millions of records and many different taxa. Those methods are usually based on geographic gazetteers [e.g., @Chamberlain2016; @Zizka2019; @Jin2020] or on additional data, such as environmental variables [@Robertson2016]. Additionally, filtering procedures based on record meta-data, such as collection year, record type, and coordinate precisions, have been proposed to improve the suitability of publicly available occurrence records for biodiversity research [@Zizka2019].

Problematic records are especially critical in conservation, where stakes are high. Recently proposed methods for automated conservation assessments could support the formal assessment procedures for the global Red List of the International Union for the Conservation of Nature (IUCN) [@Dauby2017; @Bachman2011; @Pelletier2018]. These methods approximate species' range size, namely the Extent of Occurrence (EOO, which is the area of a convex hull polygon comprising all records of a species), the Area of Occupancy (AOO, which is the sum of the area actually occupied by a species, calculated based on a small-scale regular grid), and the number of locations for a preliminary conservation assessment following IUCN Criterion B ("Geographic range"). These methods have been used to propose preliminary global [@Stevart2019; @Zizka2020b] and regional [@Schmidt2017; @Cosiaux2018] Red List assessments. However, all metrics, and especially EOO, are sensitive to individual records with problematic coordinates. Automated conservation assessments may therefore be biased, particularly if the number of records is low, as it is the case for many tropical species.

While automated filters hold great promise for biodiversity research, their use across taxonomic groups and datasets remains poorly explored. Here, we test the effect of automated filtering of species geographic occurrence records on the number of records available in different groups of animals, fungi, and plants. Furthermore, we test the impact of automated filtering procedures for the accuracy of preliminary automated conservation assessments compared to full IUCN assessments. Specifically, we evaluate a pipeline of 13 automated filters to flag possibly problematic records by using record meta-data and geographic gazetteers in two categories: 1) erroneous (coordinates, that are likely wrong, irrespective of the downstream analyses, for instance due to data entry errors) and 2) unfit for purpose (coordinates that are not wrong *per se*, but likely unfit for the planned downstream analyses, for instance because they are overly imprecise). We address three questions:

1. Which filters lead to the biggest loss of data when applied?
2. Does the importance of individual filters differ among taxonomic groups?
3. Does automated filtering improve the accuracy of automated conservation assessments?


# Material and Methods {-}
## Choice of study taxa {-}
This study is the outcome of a workshop held at the Federal University of Rio Grande do Norte in Natal, Brazil in October 2018 which gathered students and researchers working with different taxonomic groups of animals, fungi, and plants across the Neotropics (Fig. \ref{fig:species}). Each participant analysed geographic occurrence data from their taxonomic group of interest and commented on the results for their group. Hence, we include groups based on the expertise of the participants rather than following an arbitrary choice of taxa and taxonomic ranks. We acknowledge a varying degree of documented expertise and number of years working on each group. We obtained public occurrence records for 18 taxa, including one plant family, nine plant genera, one genus of fungi, three families and one genus of terrestrial arthropods, one family of snakes, one family of skates, and one genus of bony fish (Table 1).
 
## Species occurrence data {-}
<!-- @GBIForg2019; @GBIForg2019a; @GBIForg2019b; @GBIForg2019c; @GBIForg2019d; @GBIForg2019e; @GBIForg2019f; @GBIForg2019g; @GBIForg2019h; @GBIForg2019i; @GBIForg2019j; @GBIForg2019k; @GBIForg2019l; @GBIForg2019m; @GBIForg2019n; @GBIForg2019o -->

We downloaded occurrence information for all study groups from www.gbif.org using the `rgbif` v1.4.0 package [@Chamberlain2017] in R (GBIF.org, 2019a-p,2020a,b). We downloaded GBIF-interpreted data including only records with geographic coordinates and limited the study area to a rectangle between 90$^\circ$S - 33$^\circ$ N and 35$^\circ$ W - 120$^\circ$ W reflecting the Neotropics [@Morrone2014], our main area of expertise. The natural distributions of all included taxa are confined to the Neotropics except for Arhynchobatidae, Diogenidae, Dipsadidae, Entomobryidae, *Gaylussacia*, Iridaceae, Neanuridae, and *Tillandsia*, for which we only obtained the Neotropical occurrences. We consider GBIF data generally of high quality and use them as a case study because GBIF is the largest, most widely used and taxonomically most comprehensive data source for species occurrence records; however many more exist [e.g., https://bien.nceas.ucsb.edu/bien/, www.fishbase.de or @Guedes2018]. GBIF provides information on the internal consistency of records, among others including information on decimal rounding of coordinates, geographic projection and date validity and geospatial issues (including the zero coordinates test used in this study). Since we specifically aimed to test the effect of user-level filtering we included records flagged with issues by GBIF (this was also the default option). Geospatial issues flagged by GBIF only concerned 0.4% of the records used in this study and including them had the added benefit to make our results directly comparable to other databases, which may use different internal consistency checks or none at all.
 
##  Automated cleaning {-}
We followed the cleaning pipeline outlined by @Zizka2019 and first filtered the data as downloaded from GBIF ("raw", hereafter) using meta-data for those records for which they were available [although meta-data were often missing, @Peterson2018], removing: 1) records with a coordinate precision below 100 km (as this represents the grain size of many macro-ecological analyses); 2) fossil records and records of unknown source; 3) records collected before 1945 (before the end of the Second World War, since coordinates of old records are often imprecise); and 4) records with an individual count of less than one and more than 99. Furthermore, we rounded the geographic coordinates to four decimal places and retained only one record per species per location (i.e., test for duplicated records). In a second step, we used the `clean_coordinates` function of the `CoordinateCleaner v2.0-11` package [@Zizka2019] with default options to flag errors that are common to biological data sets (“filtered”, hereafter). These include: coordinates in the sea for terrestrial taxa and on land for marine taxa, coordinates containing only zeros, coordinates assigned to country and province centroids, coordinates within urban areas, and coordinates assigned to biodiversity institutions. See Table 2 for a summary of all filters we used and their classification into "erroneous" and "unfit".

## Downstream analyses {-}
We first generated species richness maps using 100x100 km grid cells for the raw and filtered datasets respectively, using the package `speciesgeocodeR v2.0-10` [@Topel2017]. We then performed an automated conservation assessment for all study groups based on both datasets using the `ConR v1.2.4` package [@Dauby2017]. `ConR` estimates the EOO, AOO, and the number of locations, and then suggests a preliminary conservation status based on Criterion B of the global IUCN Red List. While these assessments are preliminary [see @IUCN2017], they can be a proxy used by the IUCN to speed up full assessments. We then benchmarked the preliminary conservation assessments against the global IUCN Red List assessments for the same taxa (where available), which we obtained from www.iucn.org via the `rredlist v.0.5.0` package [@Chamberlain2018].

## Evaluation of results {-}
Each author provided an informed comment on the performance of the raw and cleaned datasets, concerning the number of removed records and the accuracy of the overall species richness maps. We then compared the agreement between automated conservation assessments based on raw and filtered occurrences with the global IUCN Red List for those taxa where IUCN assessments were available (www.iucn.org).

We carried out all analyses in the R computing environment [@rcoreteam2019], using standard libraries for data handling and visualization [@Wickham2018; @Garnier2018; @Ooms2014; @Ooms2019; @Hijmans2019]. All scripts are available from a zenodo repository (doi:10.5281/zenodo.3695102).

# Results {-}


We retrieved a total of 218,899 species occurrence records, with a median of 2,844 records per study group and 10 records per species (Table 3, Appendix 1). We obtained most records for Dipsadidae (64,249) and fewest for *Thozetella* (51). The species with most records was *Harengula jaguana* (19,878).

Our automated tests filtered a total of 97,004 records (Fig. \ref{fig:total}, erroneous: 9,254, unfit: 91,298), with a median of 45% per group (erroneous: 0.3%, unfit: 37.4%). Overall, the most important test was for duplicated records (on average 35.5% per taxonomic group). The filtering steps based on record meta-data that filtered the largest number of records were the basis of records (5.9%) and the collection year (3.4%). The most important automated tests were for urban area (8.6%) and the occurrence from records of terrestrial taxa in the sea and marine taxa on land (4.3%, see Table 3 and Appendix 1 in the electronic supplement for further details and the absolute numbers).  Only a few records were filtered by the coordinate precision, zero coordinates and biodiversity institution tests (Fig. \ref{fig:split}). 

Entomobryidae, Diogenidae, and Neanuridae had the highest fraction of filtered records (Table 3). In general, the different filters we tested were of similar importance for different study groups. There were few outstanding exceptions, including the particularly high proportions of records filtered by the "basis of record test" for *Tityus* (7.0%), Dipsadidae (5.6%), *Prosthechea* (5.0%) and *Tillandsia* (4.9%), by the collection year for Dipsadidae (11.3%), by the taxonomic identification level for  *Tityus* (1.6%), by the capital coordinates for *Oocephalus* (6.1%) and *Gaylussacia* (3.2%), by the seas/land test for Diogenidae and *Thozetella*, and by the urban areas test for *Oocephalus* (13.3%) and Iridaceae (12.3%). Furthermore, Entomobryidae differed considerably from all other study taxa with exceptionally high numbers of records filtered by the "basis of record", "level of identification" and "urban areas" tests.

Geographically, the records filtered by the "basis of record" and "individual count" tests were concentrated in Central America and southern North America, and a relatively high number of records were filtered due to their proximity to the centroids of political entities were located on Caribbean islands (Fig. \ref{fig:split}). See Appendix 2 for species richness maps using the raw and cleaned data for all study groups.

We found IUCN assessments for 579 species that were also included in our distribution data from 11 of our study groups (Table 4, Appendix 3). The fraction of species evaluated varied among the study group, with a maximum of 100% for *Harengula* and *Lepismium* and a minimum of 2.3% for Iridaceae (note that the number of total species varied considerably among groups). The median percentage of species per study group with an IUCN assessment was 15%. A total of 102 species were listed as *Threatened* by the IUCN global Red List (CR = 19, EN = 40, VU = 43) and 477 as *Not Threatened*.

We obtained automated conservation assessments for 2,181 species in the filtered dataset. Based on the filtered data, the automated conservation assessment evaluated 1,382 species as possibly threatened (63.4%, CR = 495, EN = 577, VU = 310, see Appendix 3 for assessments of all species). The automated assessment based on the filtered dataset agreed with the IUCN assessment for identifying species as possibly threatened (CR, EN, VU) for 358 species (64%; Table 4). Filtering reduced the EOO by 18.4% and the AOO by 9.9% on median per group. For the raw dataset the agreement with IUCN was higher at 381 species (65.7%).

# Discussion {-}
<!-- add some subheadings to discussion -->
Automated flagging based on meta-data and automatic tests filtered on average 45% of the records per taxonomic group; 25.9%-90.3% as "unfit" and 0%-44.3% as "erroneous". The filters for basis of record, duplicates, collection year, and urban areas flagged the highest fraction of records (**Question 1**). The importance of different tests was similar across taxonomic groups, with particular exceptions for the tests on basis of record, collection year, capital coordinates, and urban areas (**Question 2**). The results for species richness were similar between the raw and filtered data with some improvements using the filters. We found little impact of filtering on the accuracy of the automated conservation assessments (**Question 3**).

## The relevance of individual filters {-}
The aim of automated filtering is to identify possibly problematic records that are unsuitable for particular downstream analyses. While those records filtered as "erroneous" will likely cause problems for most biodiversity research, those filtered as "unfit" might have varying impact, depending on the type and spatial resolution of the downstream analyses. Unwanted effects include an unnecessary computational burden, which can be a bottleneck for large-scale analyses [i.e. duplicates, @Antonelli2018], and increased uncertainty (due to low precision), or completely compromising results. For instance, records assigned to country centroids might be acceptable for inter-continental comparisons, but are likely to be erroneous for species distribution modelling on a local scale. The importance of each test and the linked thresholds must be judged based on the specific downstream analyses. As our results show, it may be advisable to adapt automated tests to the geographic study area or the taxonomic study group. For instance, the high number of records flagged for centroids on the Lesser Antilles (Fig. \ref{fig:split}) might be overly strict (https://data-blog.gbif.org/post/country-centroids/), although we chose a conservative distance for the Political centroid test (1 km). 

Several factors may explain the high proportion of records flagged as duplicates. First, the deposition of duplicates from the same specimen at different institutions is common practice, especially for plants, where a specimen duplication is entirely feasible. Second, independent collections at similar localities may occur, in particular for local endemics. Third, low coordinate precision, for instance based on automated geo-referencing from locality descriptions, may lump records from nearby localities. Fourth, different data contributors might add the same record to GBIF, if their sources overlap, as can for instance be the case for the Barcode of Life and Plazi databases. 

## Similarities and differences among taxa {-}
The number of records flagged by individual tests was similar across study groups, suggesting that similar problems might be relevant for collections of plants and animals. Therefore, the same filters can be used across taxonomic groups. Some notable exceptions stress the need to adapt each filter to the taxonomic study group to balance data quality and data availability. The high fraction of records filtered by the "basis of record" filter for *Tityus*, Dipsadidae, *Prosthechea* and *Tillandsia*, were mostly caused by a high number of records in these groups based on unknown collection methods, which might be caused by the contribution of specific datasets lacking this information for these groups. The high fraction of records flagged by the "collection year" filter for Dispadidae was caused by a high collection effort in the late 1880s and early 1900s, as can be expected for a charismatic group of reptiles, but also by 500 records dated to the year 1700. The latter records likely represent a data entry error: they are all contributed to GBIF from the same institution, and the institution's code for unavailable collection dates is 1700-01-01 - 2014-01-01, which has likely erroneously been converted to 1700. The high number of species flagged at capital coordinates and within urban areas for the plant groups Iridaceae and *Oocephalus* might be related to horticulture, since at least some species in those groups are commonly cultivated as ornamentals. This was supported by the detailed examination of the data for Iridaceae, which showed that after filtering 1605 records from 69 exotic species remained in the dataset, stressing the importance to address these species in certain taxonomic groups.

The general agreement between the species richness maps based on raw and filtered data was encouraging, in terms of the use of this data for large-scale biogeographic research (Fig. \ref{fig:speciesrichness}, Appendix 2). The filter based on political centroids had an important impact on species richness patterns, which is congruent with the results from a previous study in the coffee family [@Maldonado2015]. Records assigned to country or province centroids are often old records, which are geo-referenced at a later point based on vague locality descriptions. These records are at the same time more likely to represent dubious species names, since they might be old synonyms or type specimens of species that have only been collected and described once, which are erroneously increasing species numbers.

Overall, we consider the effect of the automated filters as positive since they identified the above-mentioned issues and increased the data precision and reduced computational burden (Table 3, Appendix 2). However, in some cases filters failed to remove major issues, often due to incomplete meta-data. For instance, for Diogenidae we found at least two records of an species known only from Eocene fossils (*Paguristes mexicanus*) which slipped the "basis of record" test because they were marked as "preserved specimen" rather than "fossil specimen". Furthermore, for Entomobryidae we found that for 1,996 records the meta-data on taxonomic rank was "UNRANKED" despite all of them being identified to species level, leading to a high fraction of records removed by the "Identification level" filter. Additionally automated filters might be overly strict  or unsuitable for certain taxa. For instance, in Entomobryidae, 2,004 samples were marked as material samples and therefore removed by our global filter retaining only specimen and observation data, which in this case was overly strict. 

The filters we included in this study address a set of important but relatively easy to identify problems. In fact, the internal quality control of GBIF does flag some of the problems we tested for (i.e., zero coordinates, equal lat/lon) while others might be implemented in the near future (country centroids, https://data-blog.gbif.org/post/country-centroids/). While this internal quality is very helpful, we see a huge potential to overcome issues with data quality in a user-feedback system that allows users to provide expert assessments, i.e. a meta-annotation of records being challenged (and why). Such a system would not need to change the original data and could include multiple levels to account for differing opinions.  

As next steps for automated filtering, tests for intrinsic consistency and support by external data (if available) can help to detect additional problematic records. For instance, testing if records' coordinates fall within the state or province of collection noted for a record (intrinsic) or agree with external species distribution information, for example from www.iucn.org (vertebrates) or https://wcsp.science.kew.org/ (selected seed plant families; extrinsic) can further corroborate the accuracy of a record's geographic referencing. If such tests are included it is essential to account for the sampling year, in particular for older records, since the names of provinces may change and the ranges of species may shift. Furthermore, while in this study we focused on meta-data and geographic filtering, taxonomic cleaning---the resolution of synonymies and identification of accepted names---is another important part of data curation, but depends on taxon-specific taxonomic backbones and synonymy lists which are not readily available for many groups and often are contradictory within individual taxa. 

## The impact of filtering on the accuracy of automated conservation assessments {-}
The accuracy of the automated conservation assessment was in the same range as found by previous studies [@NicLughadha2019; @Zizka2020b]. The similar accuracy of the raw and filtered dataset for the automated conservation assessment was surprising, in particular given the EOO and AOO reduction observed in the filtered dataset (Table 4) and the impact of errors on spatial analyses observed in previous studies [@Gueta2016]. The robustness of the automated assessment was likely due to the fact that the EOO for most species was large, even after the considerable reduction caused by filtering. This might be caused by the structure of our comparison, which only included species that were evaluated by the IUCN Red List (and not considered as *Data Deficient*) and at the same time had occurrences recorded in GBIF. Those inclusion criteria are likely to have biased the datasets towards species with large ranges, since generally more data are available for them. The robustness of automated conservation assessments to data quality is encouraging, although these methods are only an approximation (and not replacements) of full IUCN Red List assessments, especially for species with few collection records [@Rivers2011].

# Conclusions {-}
Our results suggest that between one quarter to half of the occurrence records obtained from GBIF might be unsuitable for downstream biodiversity analyses. While the majority of these records might not be erroneous *per se*, they are overly imprecise and thereby increase uncertainty of downstream results or add computational burden on big data analyses. 

While our results suggest that large-scale species richness patterns and automated conservation assessments are largely resilient to the effects of problematic occurrence records, they also stress the importance of (meta-)data exploration prior to most biodiversity analyses. Automated filtering can help to identify problematic records, but also highlight the necessity to customize tests and thresholds to the specific taxonomic groups and geographic area of interest. The putative problems we encountered point to the importance to train researchers and students to curate species occurrence datasets and to visibly associate user-feedback with individual records on aggregator platforms such as GBIF so that it can contribute to the overall accuracy and precision of public biodiversity databases.

# Acknowledgements {-}
We thank GBIF and all data collectors and contributors for their excellent work. We thank Town Peterson, Roderic Page and one anonymous reviewer for the helpful comments on an earlier version of this manuscript. This study enrolled participants of the workshop "Biodiversity data: from field to yield" led by Alice Calvente, Fernanda Carvalho, Alexander Zizka, and Alexandre Antonelli through the Programa de Pós Graduação em Sistemática e Evolução of the Universidade Federal do Rio Grande do Norte (UFRN) and promoted by the 6th Conference on Comparative Biology of Monocotyledons - Monocots VI. We thank the Pró-reitoria de Pesquisa and the Pró-reitoria de Pós-graduação of UFRN for financial support (edital 02/2016 - internacionalização). AZ is funded by iDiv via the German Research Foundation (DFG FZT 118), specifically through sDiv, the Synthesis Centre of iDiv. AA is supported by the Swedish Research Council, the Knut and Alice Wallenberg Foundation, the Swedish Foundation for Strategic Research and the Royal Botanic Gardens, Kew. FS was financed by the Coordenação de Aperfeiçoamento de Pessoal de Nível Superior - Brasil (CAPES) - Finance Code 001 and Fundação de Amparo  à Pesquisa do estado de São Paulo (FAPESP) (FAPESP, process 2015/20215-7).

# Supplementary material {-}

- Appendix 1 - Absolute number of flagged records per taxonomic group and test

- Appendix 2 - Taxon-specific richness maps and comments

- Appendix 3 - Full results of the conservation assessment

\newpage{}

# Tables {-}
\newpage{}
<!-- A table presenting the study taxa -->

```
## Error in (function (classes, fdef, mtable) : unable to find an inherited method for function 'select' for signature '"tbl_df"'
```

```
## Error in dimnames(x) <- dn: length of 'dimnames' [2] not equal to array extent
```

<!-- A table briefly describing the tests we ran -->
\begin{table}[!h]

\caption{\label{tab:tabletests}The automated filters used in this study.}
\centering
\fontsize{9}{11}\selectfont
\begin{tabular}[t]{>{\raggedright\arraybackslash}p{2cm}>{\raggedright\arraybackslash}p{1cm}>{\raggedright\arraybackslash}p{2.5cm}>{\raggedright\arraybackslash}p{9cm}}
\toprule
Test & Type & Basis & Rationale\\
\midrule
\rowcolor{gray!6}  Biodiversity institutions & Error & Gazetteer-based & Records may have coordinates at the location of biodiversity institutions, e.g. because they were erroneously entered with the physical location of the specimen or because they represent individuals from captivity or horticulture, which are not clearly labeled as such\\
Equal lat/lon & Error & Gazetteer-based & Coordinates with equal latitude and longitude are usually indicative of data entry errors\\
\rowcolor{gray!6}  Sea & Error & Gazetteer-based & Coordinates from terrestrial organisms in the sea are usually indicative of data entry errors, e.g. swapped latitude and longitude\\
Zeros & Error & Gazetteer-based & Coordinates with plain zeros are often indicative of data entry errors\\
\rowcolor{gray!6}  Capitals & Unfit & Gazetteer-based & Records may be assigned to the coordinates of country capitals based on a vague locality description\\
\addlinespace
Duplicates & Unfit & Gazetteer-based & Duplicated records may add unnecessary computational burden, in particular for large scale biodiversity analyses and distribution modelling for many species\\
\rowcolor{gray!6}  Political centroids & Unfit & Gazetteer-based & Records may be assigned to the coordinates of the centroids of political entities based on a vague locality description\\
Urban areas & Unfit & Gazetteer-based & Records from urban areas are not necessarily errors, but often represent imprecise records automatically geo-referenced from vague locality descriptions or old records from different land-use types\\
\rowcolor{gray!6}  Basis of record & Unfit & Meta-data & Records might be unsuitable or unreliable for certain analyses dependent on their source, e.g. 'fossil' or 'unknown'\\
Collection year & Unfit & Meta-data & Coordinates from old records are more likely to be imprecise or erroneous coordinates since they are derived from  geo-referencing based on the locality description. This is more problematic for older records, since names or borders of places may change\\
\addlinespace
\rowcolor{gray!6}  Coordinate precision & Unfit & Meta-data & Records may be unsuitable for a study if their precision is lower than the study analysis scale\\
Identification level & Unfit & Meta-data & Records may be unsuitable if they are not identified to species level.\\
\rowcolor{gray!6}  Individual count & Unfit & Meta-data & Records may be unsuitable if the number of recorded individuals is 0 (record of absence) or if the count is too high, as this is often related to records from barcoding or indicative of data entry problems.\\
\bottomrule
\end{tabular}
\end{table}


<!-- A table presenting the overall results, the decrease in records by filtering, the change in conservation status -->

```
## Error in (function (classes, fdef, mtable) : unable to find an inherited method for function 'select' for signature '"tbl_df"'
```

```
## Error in dimnames(x) <- dn: length of 'dimnames' [2] not equal to array extent
```



\begin{landscape}\begin{table}

\caption{\label{tab:unnamed-chunk-3}Conservation assessment for 11 Neotropical taxa of plants and animals based on three datasets. IUCN: global red list assessment obtained from www.iucn.org; GBIF Raw: preliminary conservation assessment based on IUCN Criterion B using ConR and the raw dataset from GBIF; GBIF filtered: preliminary conservation assessment based on IUCN Criterion B using ConR and the filtered dataset. Only taxa with at least one species evaluated by IUCN shown.}
\centering
\fontsize{9}{11}\selectfont
\begin{tabular}[t]{l>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.2cm}>{\raggedleft\arraybackslash}p{1.5cm}>{\raggedleft\arraybackslash}p{1.5cm}}
\toprule
\multicolumn{1}{c}{ } & \multicolumn{3}{c}{IUCN} & \multicolumn{3}{c}{GBIF Raw} & \multicolumn{5}{c}{GBIF Filtered} \\
\cmidrule(l{3pt}r{3pt}){2-4} \cmidrule(l{3pt}r{3pt}){5-7} \cmidrule(l{3pt}r{3pt}){8-12}
Taxon & n taxa & Evaluated [\%] & Threatened [\%] & n taxa & Threatened [\%] & Match with IUCN [\%] & n taxa & Threatened [\%] & Match with IUCN [\%] & EOO change compared to raw [\%] & AOO change compared to raw [\%]\\
\midrule
Arhynchobatidae & 37 & 51.3 & 17.9 & 39 & 35.9 & 45.0 & 39 & 41.0 & 40.0 & -32.7 & -18.5\\
Dipsadidae & 520 & 68.0 & 8.8 & 638 & 58.3 & 63.0 & 598 & 59.9 & 61.2 & -2.3 & -15.6\\
\em{Harengula} & 4 & 100.0 & 0.0 & 4 & 0.0 & 100.0 & 4 & 0.0 & 100.0 & -38.0 & -36.9\\
\hline
\em{Conchocarpus} & 4 & 8.7 & 0.0 & 46 & 63.0 & 100.0 & 45 & 62.2 & 100.0 & -15.3 & -7.1\\
\em{Gaylussacia} & 2 & 3.3 & 0.0 & 61 & 59.0 & 50.0 & 58 & 60.3 & 50.0 & -22.5 & -8.6\\
\addlinespace
\em{Harpalyce} & 3 & 15.0 & 5.0 & 20 & 65.0 & 66.7 & 17 & 58.8 & 50.0 & -18.4 & -16.5\\
Iridaceae & 13 & 2.3 & 0.2 & 531 & 64.4 & 50.0 & 466 & 62.9 & 62.5 & -18.2 & -12.3\\
\em{Lepismium} & 6 & 100.0 & 0.0 & 6 & 16.7 & 83.3 & 6 & 16.7 & 83.3 & -33.9 & -7.9\\
\em{Pilosocereus} & 41 & 80.9 & 19.1 & 47 & 55.3 & 73.7 & 46 & 56.5 & 71.1 & -8.5 & -5.8\\
\em{Tillandsia} & 54 & 11.6 & 6.0 & 464 & 61.4 & 85.2 & 453 & 62.7 & 83.3 & -13.7 & -9.9\\
\addlinespace
\em{Tocoyena} & 3 & 13.6 & 4.5 & 22 & 31.8 & 66.7 & 21 & 38.1 & 66.7 & -23.0 & -9.5\\
\bottomrule
\end{tabular}
\end{table}
\end{landscape}

# Figures {-}
<!-- The study species-->
<img src="./figures_tables/Fig1_study_groups.png" title="Examples of taxa included in this study. \textbf{A)} \textit{Pilosocereus pusillibaccatus} (\textit{Pilosocereus}), \textbf{B)} \textit{Conchocarpus macrocarpus} (\textit{Conchocarpus}); \textbf{C)} \textit{Tillandsia recurva} (\textit{Tillandsia}); \textbf{D)} \textit{Oxyrhopus guibei} (Dipsadidae); \textbf{E)} \textit{Aethiopella ricardoi} (Neanuridae); \textbf{F)} \textit{Tocoyena formosa} (\textit{Tocoyena}); \textbf{G)} \textit{Harengula jaguana} (\textit{Harengula}); \textbf{H)} \textit{Gaylussacia decipiens} (\textit{Gaylussacia}); \textbf{I)} \textit{Oocephalus foliosus} (\textit{Oocephalus}); \textbf{J)} \textit{Tityus carvalhoi} (\textit{Tityus}); \textbf{K)} \textit{Prosthechea vespa} (\textit{Prosthechea}), Image credits: A) Pamela Lavor, B) Juliana El-Ottra, C) Eduardo Calisto Tomaz, D) Filipe C Serrano, E) Raiane Vital da Paz, F) Fernanda GL Moreira, G) Thais Ferreira-Araujo, H) Luiz Menini Neto, I) Arthur de Souza Soares, J) Renata C Santos-Costa, K) Tiago Vieira." alt="Examples of taxa included in this study. \textbf{A)} \textit{Pilosocereus pusillibaccatus} (\textit{Pilosocereus}), \textbf{B)} \textit{Conchocarpus macrocarpus} (\textit{Conchocarpus}); \textbf{C)} \textit{Tillandsia recurva} (\textit{Tillandsia}); \textbf{D)} \textit{Oxyrhopus guibei} (Dipsadidae); \textbf{E)} \textit{Aethiopella ricardoi} (Neanuridae); \textbf{F)} \textit{Tocoyena formosa} (\textit{Tocoyena}); \textbf{G)} \textit{Harengula jaguana} (\textit{Harengula}); \textbf{H)} \textit{Gaylussacia decipiens} (\textit{Gaylussacia}); \textbf{I)} \textit{Oocephalus foliosus} (\textit{Oocephalus}); \textbf{J)} \textit{Tityus carvalhoi} (\textit{Tityus}); \textbf{K)} \textit{Prosthechea vespa} (\textit{Prosthechea}), Image credits: A) Pamela Lavor, B) Juliana El-Ottra, C) Eduardo Calisto Tomaz, D) Filipe C Serrano, E) Raiane Vital da Paz, F) Fernanda GL Moreira, G) Thais Ferreira-Araujo, H) Luiz Menini Neto, I) Arthur de Souza Soares, J) Renata C Santos-Costa, K) Tiago Vieira." width="0.9\linewidth" />


<!-- A map with number of species and where they have been removed -->
<img src="./figures_tables/Fig2_number_of_records.png" title="The absolute number of records flagged as erroneous or unfit by automated geographic filters in dataset of 18 Neotropical taxa including animals, fungi, and plants, plotted in a 100 x 100 km grid across the Neotropics (Behrmann projection)." alt="The absolute number of records flagged as erroneous or unfit by automated geographic filters in dataset of 18 Neotropical taxa including animals, fungi, and plants, plotted in a 100 x 100 km grid across the Neotropics (Behrmann projection)." width="\linewidth" />



<img src="./figures_tables/Fig3_number_of_records_split.png" title="Geographic location of the occurrence records flagged by the automated tests applied in this study. Only filters that flagged at least 0.1\% of records in any taxon are shown." alt="Geographic location of the occurrence records flagged by the automated tests applied in this study. Only filters that flagged at least 0.1\% of records in any taxon are shown." width="\linewidth" />



<img src="./figures_tables/Fig4_number_species_richness_difference.png" title="Illustrative examples for the difference in species richness between the raw and filtered dataset (raw - filtered) from four of the study taxa. Total species number in the raw data sets: Dipsadidae: 637, \textit{Harengula}: 4, \textit{Thozetella}: 9, \textit{Tillandsia} 464.  Photo credits for C) by Tiago Andrade Borges Santos, otherwise as in Figure 1." alt="Illustrative examples for the difference in species richness between the raw and filtered dataset (raw - filtered) from four of the study taxa. Total species number in the raw data sets: Dipsadidae: 637, \textit{Harengula}: 4, \textit{Thozetella}: 9, \textit{Tillandsia} 464.  Photo credits for C) by Tiago Andrade Borges Santos, otherwise as in Figure 1." width="\linewidth" />

\newpage{}
# References {-}
