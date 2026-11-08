import pandas as pd
import pandas_gbq
import os
import glob as glob
import config

x=glob.glob(os.path.join(config.csv_file,'*.csv'))


gbq_project_name=config.project_id
gbq_dataset_name=config.dataset_name

for data in x:
    y=pd.read_csv(data)
    y.columns=y.columns.str.replace(r'[\.\s\(\)]+','_',regex=True).str.strip('_')

    file_name=os.path.basename(data).replace('.csv','')
    new_name=f'extracted_{file_name}'

  
    

    full_path=f'{gbq_dataset_name}.{new_name}'

    pandas_gbq.to_gbq(
        y,
        project_id=gbq_project_name,
        destination_table=full_path,
        if_exists='replace'
    )