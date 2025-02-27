from bit import Key
from multiprocessing import cpu_count, Process
import sys
from timeit import default_timer

mean_of = 3

def test_wallet(start, end):
    for i in range(start, end+1):
        pk = Key.from_int(i)
        if pk.address in wallets:
            with open('found.txt', 'a') as result:
                result.write(f'ADDR:{pk.address} - PK:{pk.to_wif()}\n')
            print(f'\n *** Added address to found.txt ***')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f' - Parameters : amount_wallets, n_jobs_test ') 
        exit()

    print(f'> Starting - Bitcoin Brute Force') 
    print(f'> CPU count: {cpu_count()}')
    
    print(f'> Reading Wallets') 
    # Read file.txt - have inside wallets with balances
    wallets = open('wallets_bitcoin.txt', 'r').read()
    lines = wallets.count('\n')
    print(f'> {lines:,} Wallets Loaded\n')

    print('>>> Starting Brute Force <<<\n')
 
    amount_wallets = int(sys.argv[1])
    n_jobs_test = int(sys.argv[2])
    
    # Benchmark of code. Using n_jobs_test as number of threads and make mean of 3 repetitions
    # need start in 1 because 0 threads not exist
    for i in range(1,n_jobs_test+1): # i =[1,2,3,n_jobs_test]
        init_pos = 1
        process = []
        cpu_iteration = int(amount_wallets/i) 
        rest = amount_wallets%i
        
        mean = default_timer() # get time now

        for _ in range(mean_of):
            for j in range(i):
                
                if j == 0:
                    p = Process(target=test_wallet, args=( 1, cpu_iteration + rest)) 
                    init_pos += cpu_iteration + rest                                 
                else:    
                    p = Process(target=test_wallet, args=( init_pos, init_pos + cpu_iteration -1))
                    init_pos += cpu_iteration
                
                process.append(p)
                p.start()
                
            # Waiting all threads end
            for p in process:
                p.join()
            
            init_pos = 1

        mean = (default_timer()-mean)/mean_of    # calculate the mean of rounds   
        print(f'> Test with {i} processes - {round(mean, 2)} seconds - {round((amount_wallets/mean),2)} wallets/s') 

    print('\n>>> End Brute Force <<<')           
