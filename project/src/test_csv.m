function test_csv()
    fileID = fopen('./csvfile.csv', 'w');
    fprintf(fileID, 'first,second,third,fourth,fifth\n');
    format = '%f,%f,%f,%f,%f\n';
    A = [1 2 3 4 5];
    for i = 1:10
        fprintf(fileID, format, A.*i);
    end
    fclose(fileID);
end