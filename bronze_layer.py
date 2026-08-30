import pandas as pd
import pandas_gbq
import os
import glob as glob

x=glob.glob(r'C:\Users\Tanvir\Downloads\FAOSTAT Agriculture Data\*.csv')

for data in x:
    y=pd.read_csv(data)
    y.columns=y.columns.str.replace(r'[\.\s\(\)]+','_',regex=True).str.strip('_')

    file_name=os.path.basename(data).replace('.csv','')
    new_name=os.path.join(f'extracted_{file_name}')

    gbq_project_name='elite-vista-474514-t0'
    gbq_dataset_name='Bronze_FAOSTAT_Agriculture_Data'
    gbq_table_name=new_name

    full_path=f'{gbq_dataset_name}.{gbq_table_name}'

    pandas_gbq.to_gbq(
        y,
        project_id=gbq_project_name,
        destination_table=full_path,
        if_exists='append'
    )