//
// Created by MIGUEL MOLDES on 12/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

class RTDeleteRecordsOperation {

    let maxRetryTimes = 5
    var batchSize = 500
    var retryTimes = 0
    var allBatchedRecords = [[CKRecordID]]()
    var allRecords = [CKRecordID]()


    func deleteRecords(records:[CKRecord]){
        self.allRecords = self.getRecordsIDs(records)
        self.allBatchedRecords = self.allRecords.splitBy(batchSize)
        self.deleteBatch()
    }


    private func deleteBatch() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase

        let uploadOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: self.allBatchedRecords[0])

        uploadOperation.atomic = false
        uploadOperation.database = privateDatabase

        uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: NSError?) -> Void in
            self.removeDeletedElements(deletedRecords)
            if let error = operationError {
                switch error.code {
                case CKErrorCode.LimitExceeded.rawValue:
                    print("Limit exceeded")
                    self.rebatch()
                    self.retryDeleting()
                    break
                default:
                    self.retryDeleting()
                    break
                }

                print(error)
                return
            }

            self.retryTimes = 0

            if self.allBatchedRecords.count == 0 {
                return
            }

            self.deleteBatch()
        }

        NSOperationQueue().addOperation(uploadOperation)
    }

    private func getRecordsIDs(records:[CKRecord]) -> [CKRecordID] {
        var recordsID = [CKRecordID]()
        for record : CKRecord in records {
            recordsID.append(record.recordID)
        }
        return recordsID
    }

    private func removeDeletedElements(deletedRecords: [CKRecordID]?) {
        if deletedRecords != nil && deletedRecords!.count > 0 {
            for record : CKRecordID in deletedRecords! {
                if self.allBatchedRecords[0].contains(record) {
                    self.allBatchedRecords[0].removeAtIndex(self.allBatchedRecords[0].indexOf(record)!)
                }
            }
        }
        if self.allBatchedRecords[0].count == 0 {
            self.allBatchedRecords.removeAtIndex(0)
        }
    }

    private func rebatch(){
        self.batchSize = Int(self.batchSize / 2)
        var recordsToDelete = [CKRecordID]()
        for recordsBatch in self.allBatchedRecords {
            for record in recordsBatch {
                recordsToDelete.append(record)
            }
        }

        self.allBatchedRecords = recordsToDelete.splitBy(self.batchSize)
    }

    private func retryDeleting(){
        self.retryTimes = self.retryTimes + 1
        if self.retryTimes == self.maxRetryTimes {
            return
        }
        self.deleteBatch()
    }

}