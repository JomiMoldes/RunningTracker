//
// Created by MIGUEL MOLDES on 9/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

class RTSaveRecordsOperation {

    let maxRetryTimes = 3
    var batchSize = 500
    var allBatchedRecords = [[CKRecord]]()
    var allSavedRecords = [CKRecord]()
    var allRecords = [CKRecord]()
    var retryTimes = 0
    var completion : () -> Void = {}

    func saveRecord(records:[CKRecord], completion:()->Void){
        self.allRecords = records
        self.allBatchedRecords = records.splitBy(batchSize)
        self.completion = completion
        self.saveBatch()
    }

    private func saveBatch() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase

        let uploadOperation = CKModifyRecordsOperation(recordsToSave: self.allBatchedRecords[0], recordIDsToDelete: nil)

        uploadOperation.atomic = false
        uploadOperation.database = privateDatabase

        uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: NSError?) -> Void in
            self.removeSavedElements(savedRecords)
            if let error = operationError {

                switch error.code {
                    case CKErrorCode.LimitExceeded.rawValue:
                        self.rebatch()
                        self.retrySaving()
                        break
                    default:
                        self.retrySaving()
                        break
                }

                print(operationError)
                return
            }

            self.retryTimes = 0

            if self.allBatchedRecords.count == 0 {
                self.completion()
                return
            }
            self.saveBatch()
        }

        NSOperationQueue().addOperation(uploadOperation)
    }

    private func removeSavedElements(savedRecords: [CKRecord]?) {
        if savedRecords != nil && savedRecords!.count > 0 {
            for record : CKRecord in savedRecords! {
                if self.allBatchedRecords[0].contains(record) {
                    self.allBatchedRecords[0].removeAtIndex(self.allBatchedRecords[0].indexOf(record)!)
                }
                allSavedRecords.append(record)
            }
        }
        if self.allBatchedRecords[0].count == 0 {
            self.allBatchedRecords.removeAtIndex(0)
        }
    }

    private func rebatch(){
        self.batchSize = Int(self.batchSize / 2)
        var recordsToSave = [CKRecord]()
        for recordsBatch in self.allBatchedRecords {
            for record in recordsBatch {
                recordsToSave.append(record)
            }
        }

        self.allBatchedRecords = recordsToSave.splitBy(self.batchSize)
    }

    private func retrySaving(){
        self.retryTimes = self.retryTimes + 1
        if self.retryTimes == self.maxRetryTimes {
            self.rollback()
            return
        }
        self.saveBatch()
    }

    private func rollback(){
        let deleteOperation = RTDeleteRecordsOperation()
        deleteOperation.deleteRecords(self.allSavedRecords)
        self.completion()
    }

}
