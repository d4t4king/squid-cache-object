<?php

//+----------------------------------------------------------------------+
//| SquidCacheObject v0.6                                                |
//+----------------------------------------------------------------------+
//| Copyright (c) 2006 Warren Smith ( smythinc 'at' gmail 'dot' com )    |
//+----------------------------------------------------------------------+
//| This library is free software; you can redistribute it and/or modify |
//| it under the terms of the GNU Lesser General Public License as       |
//| published by the Free Software Foundation; either version 2.1 of the |
//| License, or (at your option) any later version.                      |
//|                                                                      |
//| This library is distributed in the hope that it will be useful, but  |
//| WITHOUT ANY WARRANTY; without even the implied warranty of           |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    |
//| Lesser General Public License for more details.                      |
//|                                                                      |
//| You should have received a copy of the GNU Lesser General Public     |
//| License along with this library; if not, write to the Free Software  |
//| Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 |
//| USA                                                                  |
//+----------------------------------------------------------------------+
//| Simple is good.                                                      |
//+----------------------------------------------------------------------+
//

/*
  +----------------------------------------------------------------------+
  | Package: SquidCacheObject v0.6                                       |
  | Class  : SquidCacheObject                                            |
  | Created: 25/08/2006                                                  |
  +----------------------------------------------------------------------+
*/

/*---------------*/
/* D E F I N E S */
/*---------------*/

// These are the different meta types from enums.h in the Squid source
define('STORE_META_VOID'       , 0);
define('STORE_META_KEY_URL'    , 1);
define('STORE_META_KEY_SHA'    , 2);
define('STORE_META_KEY_MD5'    , 3);
define('STORE_META_URL'        , 4);
define('STORE_META_STD'        , 5);
define('STORE_META_HITMETERING', 6);
define('STORE_META_VALID'      , 7);
define('STORE_META_END'        , 8);

class SquidCacheObject {

    /*-------------------*/
    /* V A R I A B L E S */
    /*-------------------*/

    // Public Properties

    /**
    * string
    *
    * This is a key for the URL
    */
    var $KeyURL = '';

    /**
    * string
    *
    * This is a unique SHA hash for the cache object
    */
    var $KeySHA = '';

    /**
    * string
    *
    * This is a unique MD5 hash for the cache object
    */
    var $KeyMD5 = '';

    /**
    * string
    *
    * This is the original URL of the content that this cache object holds
    */
    var $URL = '';

    /**
    * string
    *
    * This is the human readable file size of the cache object file
    */
    var $Size = '';

    /**
    * string
    *
    * A human readable date representing the cache objects creation date
    */
    var $Created = '';

    /**
    * string
    *
    * A human readable date representing the cache objects last modified date
    */
    var $Modified = '';

    /**
    * string
    *
    * This is all the original HTTP headers as they appear in the cache object
    */
    var $Headers = '';

    /**
    * string
    *
    * This is the cached content as it appears in the cache object
    */
    var $Data = '';

    // Private Properties

    /**
    * integer
    *
    * This is the length of the meta data segment in the cache object file
    */
    var $MetaDataLength = 0;

    /**
    * boolean
    *
    * This will determine if we parse all data or just the meta data headers in a Squid cache object
    */
    var $HeaderOnly = FALSE;

    /*-------------------*/
    /* F U N C T I O N S */
    /*-------------------*/

    /*
      +------------------------------------------------------------------+
      | Constructor                                                      |
      |                                                                  |
      | @return void                                                     |
      +------------------------------------------------------------------+
    */

    function SquidCacheObject($cacheObject = '', $headerOnly = FALSE){

        // If we have a cache object
        if ($cacheObject){

            // No useless messages please
            error_reporting(E_ERROR);

            // Set the header only flag
            $this->HeaderOnly = $headerOnly;

            // Load it
            $this->Load($cacheObject);
        }
    }

    /*
      +------------------------------------------------------------------+
      | Load a cache object and parse it into a program object           |
      |                                                                  |
      | @return boolean                                                  |
      +------------------------------------------------------------------+
    */

    function Load($cacheObject = ''){

        // If the squid cache object exists
        if (file_exists($cacheObject)){

            // If the file is readable
            if (is_readable($cacheObject)){

                // First record the cache objects file size
                $this->Size = $this->HumanReadable(filesize($cacheObject));

                // Set the modified and created properties
                $this->Created  = date('d/m/Y', filectime($cacheObject));
                $this->Modified = date('d/m/Y', filemtime($cacheObject));

                // Open a file pointer for reading binary
                $Pointer = fopen($cacheObject, 'rb');

                // If we have a pointer
                if ($Pointer){

                    // Find out how big the meta data header is
                    $Size = strlen(pack('CI', STORE_META_VOID, 0));

                    // Read the meta data header
                    $MetaDataHeader = unpack('CType/@1/ILength', fread($Pointer, $Size));

                    // If this looks like a Squid cache object
                    if ($MetaDataHeader['Type'] == 3){

                        // Set the meta data length
                        $this->MetaDataLength = $MetaDataHeader['Length'];

                        // Loop through the meta data segment
                        while (!ftell($Pointer) < $this->MetaDataLength){

                            // Get the current position of the file pointer
                            $PointerPosition = ftell($Pointer);

                            // Read the next meta data tuple
                            $RawData = fread($Pointer, $Size);

                            // If the first character is a newline, we're done
                            if (ord($RawData[0]) == 10){

                                // Return the file pointer to its first position plus one byte
                                fseek($Pointer, $PointerPosition + 1);

                                // Exit this loop, we have all our meta data
                                break;
                            }

                            // Unpack the meta data tuples type and length
                            $MetaData = unpack('CType/@1/ILength', $RawData);

                            // Read the meta data value from the file pointer
                            $Value = fread($Pointer, $MetaData['Length']);

                            // Handle different meta data types differently
                            switch ($MetaData['Type']){

                                // MD5 of URL
                                case STORE_META_KEY_MD5:

                                    // Convert this binary hash into a string and store it as a property
                                    $this->KeyMD5 = $this->HexString($Value);

                                    break;

                                // The URL of the content this cache object holds
                                case STORE_META_URL:

                                    // Just add the URL as a property minus that nasty NULL byte
                                    $this->URL = substr($Value, 0, -1);

                                    break;
                            }
                        }

                        // If we are not getting the headers only
                        if (!$this->HeaderOnly){

                            // Loop through the HTTP header and file data
                            while (!feof($Pointer)){

                                // Get the next chunk of data from the file pointer
                                $Data = unpack('CByte', fread($Pointer, 1));

                                // If we already have the headers
                                if (substr($this->Headers, -4) == "\x0D\x0A\x0D\x0A"){

                                    // Then we just add this to the file data
                                    $this->Data .= chr($Data['Byte']);

                                } else {

                                    // Add this byte to the headers property
                                    $this->Headers .= chr($Data['Byte']);
                                }
                            }
                        }

                        // Close the file pointer
                        fclose($Pointer);

                        // If we got here we were successfull
                        return TRUE;

                    } else {

                        // Close the cache file
                        fclose($Pointer);

                        // Show the error to the user
                        $this->Error('You did not specify a valid Squid cache object or the cache object is corrupted');

                        // This does not look like a cache file
                        return FALSE;
                    }

                } else {

                    // Tell the user about the error
                    $this->Error('Could not open the specified cache file for reading');

                    // Failure
                    return FALSE;
                }

            } else {

                // Show the error to the user
                $this->Error('Insufficient permissions to read the chache file specified');

                // Failure
                return FALSE;
            }

        } else {

            // Show the error to the user
            $this->Error('The cache file specified does not exists');

            // No luck
            return FALSE;
        }
    }

    /*
      +------------------------------------------------------------------+
      | This will get the hex string for some bytes                      |
      |                                                                  |
      | @return string                                                   |
      +------------------------------------------------------------------+
    */

    function HexString($bytes = ''){

        // This is the string we will be returning
        $return = '';

        // If we have some bytes to loop through
        if ($bytes){

            // Loop through the bytes
            for ($i = 0; $i < strlen($bytes); $i++){

                // Get the hex value for this byte
                $Hex = dechex(ord($bytes[$i]));

                // If this hex value is only 1 character in length, add a preceding 0
                if (strlen($Hex) == 1) $Hex = '0'.$Hex;

                // Add this hex value to the final string
                $return .= $Hex;
            }
        }

        // Return the final string
        return $return;
    }

    /*
      +------------------------------------------------------------------+
      | Make's a user readable file size string from the byte value      |
      |                                                                  |
      | @return String                                                     |
      +------------------------------------------------------------------+
    */

    function HumanReadable($bytes = 0){

        // This is the string we will be returning
        $return = '';

        // If we have a file smaller than a kilobyte
        if ($bytes < 1024){

            // We are dealing with bytes
            $return = $bytes.' bytes';

        // If we have less than a megabyte
        } elseif ($bytes < 1048576){

            // We are dealing with kilobytes
            $return = round($bytes / 1024).' KB';

        } else {

            // We are dealing with megabytes
            $return = round($bytes / 1048576).' MB';
        }

        // Return the final string
        return $return;
    }

    /*
      +------------------------------------------------------------------+
      | Report an error to the user specific to thier environment        |
      |                                                                  |
      | @return void                                                     |
      +------------------------------------------------------------------+
    */

    function Error($msg = ''){

        // If we have a message to show
        if ($msg){

            // If we were called from the command line
            if (!$_SERVER['REQUEST_METHOD']){

                // Format the message for the command line interface
                $msg = '[+] '.$msg."\n";

            } else {

                // Format the message for the web
                $msg = '<span style="color: red; font-weight: bold;">Error: '.htmlspecialchars($msg).'</span><br />';
            }

            // Show the final error message
            echo $msg;
        }
    }
}

?>
