#!/bin/bash
#
# Script: get-remote-fastq-header.sh
# Description: Downloads a small part of a larger fastq.gz file from AWS S3,
#              extracts the first header field to gather metadata such as the
#              flowcell ID.
# Author: LWPembleton
# Date: June 22, 2023
#
# Usage:
#     bash get-remote-fastq-header.sh <file-with-s3-paths>
#
# Arguments:
#     <file-with-s3-paths.txt>: Text file containing the full S3 paths to the
#                              relevant fastq.gz files.
#
# Output:
#     A tab-separated text file with the S3 file path and the first header field.
#
# Example:
#     bash get-remote-fastq-header.sh file_paths.txt
#
# Dependencies:
#     - AWS CLI (configured with appropriate credentials)
#     - zcat
#     - sed
#
# Notes:
#     - This script assumes that the AWS CLI and other required dependencies are
#       already installed and configured.
#     - The script requires proper access and permissions to download the files
#       from AWS S3.
#     - The script assumes the fastq files are gzipped
#


# input parameters
s3_files=$1

echo "list of s3 files: $s3_files"

echo -e "s3_fastq_file\tfastq_header1" > fastq_headers.txt
for f in $(cat $s3_files); do
    
    echo "extracting fastq header from $f"

    bucket_name=$(echo $f | sed 's/s3:\/\///' | cut -d '/' -f 1)
    key_path=$(echo $f | sed 's/s3:\/\///' | sed 's/[^/]*\/*\///')

    aws s3api get-object --bucket $bucket_name --key $key_path --range bytes=0-1000 temp_file.gz  
    fastq_header=$(zcat temp_file.gz 2>/dev/null | head -n 1)

    echo -e "$f\t$fastq_header" >> fastq_headers.txt

    rm temp_file.gz

done
