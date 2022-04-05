# azure-bicep-templates
In this reference architecture, I will deploy a data management landing zone, which is needed for common governance, and a single data landing zone which can be used by the organisation with option of adding more as per the need.

Data management landing zone
A critical concept for every data management and analytics scenario is having one data management landing zone. This subscription contains resources that will be shared across all of the landing zones. This includes shared networking components like a firewall and private DNS zones. It also includes resources for data and cloud governance, such as Azure Policy and Azure Purview. to be added.

Data integrations
There are two landing zones. The first zone for test and second for production. it will ingest data from all the sources for a project.

These integrations won't transform or enrich the data. They only copy the data from the source systems and land it in the raw layer.
This allows many data products to consume the data in a scalable manner without putting another burden on the source system.
