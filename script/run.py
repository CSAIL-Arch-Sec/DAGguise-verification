
import os
import time

#-------------------- 1/2 Run Config Begin --------------------
RUN_MODE = "multiProc" # singleProc, multiProc, slurmCluster
NUM_MULTIPROC_THREAD = None # use `None` to automatically detect num_cores on the machine
#-------------------- 1/2 Run Config End --------------------


#-------------------- 2/2 Sweep Param Config Begin --------------------
experimentList = []
i = 0
for cycle in range(13, 21):
  for hist in range(2, 10):
    i += 1
    experimentList.append([i, hist, cycle]) #[index, hist, cycle]
#-------------------- 2/2 Sweep Param End --------------------




def initClient(RUN_MODE):
  from dask.distributed import Client

  # STEP1 choose a cluster
  if RUN_MODE == "multiProc":
    from dask.distributed import LocalCluster
    cluster = LocalCluster(n_workers=NUM_MULTIPROC_THREAD, threads_per_worker=1, local_directory="/tmp")
  
  elif RUN_MODE == "slurmCluster":
    from dask_jobqueue import SLURMCluster
    cluster = SLURMCluster(cores=64, processes=64, memory="250G", interface="ib0", walltime="24:00:00", local_directory="/tmp")
    #cluster.adapt(minimum_jobs=1, maximum_jobs=2, wait_count=100)
    cluster.scale(jobs=6)
  
  else:
    assert(False)

  time.sleep(1)
  print(cluster)

  # STEP2 setup a client
  client = Client(cluster)

  return client


def runSimu(index_hist_cycle):

  startTime = time.time()

  command = "raco test ++args \"--hist %d --cycle %d\" -o result/%d-hist%d-cycle%d src/checkSecu.rkt" %\
    (index_hist_cycle[1], index_hist_cycle[2], index_hist_cycle[0], index_hist_cycle[1], index_hist_cycle[2])
  print('[command to run]: ', command)
  os.system(command)

  print("----------> Finish %d-th Simu, After %f minutes" %\
    (index_hist_cycle[0], (time.time() - startTime)/60))



if __name__ == "__main__":
  os.makedirs("result", exist_ok=True)

  if RUN_MODE == "singleProc":
    for i, index_config_app in enumerate(experimentList):
      runSimu(index_config_app)

  else:
    client = initClient(RUN_MODE)
    futureList = []
    for index_config_app in experimentList:
      futureList.append(client.submit(runSimu, index_config_app))
      time.sleep(0.1)

    for i, future in enumerate(futureList):
      future.result()

