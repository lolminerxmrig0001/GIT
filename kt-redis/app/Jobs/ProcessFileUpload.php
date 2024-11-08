<?php

namespace App\Jobs;

use App\Jobs\ConvertFileUploadRecord;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;
use League\Csv\Reader;
use League\Csv\Statement;

class ProcessFileUpload implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $fileUpload;

    public $timeout = 3600;

    /**
     * Create a new job instance.
     *
     * @return void
     */
    public function __construct($fileUpload)
    {
        $this->onQueue('process-file-uploads');
        $this->fileUpload = $fileUpload->load('catalog', 'team');
    }

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        $mapping = $this->fileUpload->mapping;
		$storagePath  = Storage::disk('local')->getDriver()->getAdapter()->getPathPrefix();
		
        $file = $storagePath."public/".$this->fileUpload->path;
        /*  $file = Storage::get($this->fileUpload->path);
		
		$csv = Reader::createFromString($file);
		
        $statement = new Statement;
        $statement = $statement->offset(1); 
		foreach ($statement->process($csv) as $key => $record) {
            $record = array_map(fn($value) => utf8_encode(is_array($value) ? $value[0] : $value), $record);
			echo"<pre/>";print_r($record);

            ConvertFileUploadRecord::dispatch($this->fileUpload, $record);
        }
		
		*/
		
		$csvFile = file($file);
		
		$i=0;
		foreach ($csvFile as $line) {
			if($i>0){
				$record = str_getcsv($line);
				$record = array_map(fn($value) => utf8_encode(is_array($value) ? $value[0] : $value), $record);
				
				ConvertFileUploadRecord::dispatch($this->fileUpload, $record);
			}
			$i++;
			//echo"<pre/>";print_r($line);
		}

        
    }

    public function tags()
    {
        return ['ProcessFileUpload', 'file_upload:' . $this->fileUpload->id];
    }
}
