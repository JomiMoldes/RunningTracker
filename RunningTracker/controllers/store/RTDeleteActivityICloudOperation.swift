//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTDeleteActivityICloudOperation {

    let maxRetryTimes = 5
    var batchSize = 500
    var retryTimes = 0
    var allBatchedRecords = [[CKRecordID]]()
    var allRecords = [CKRecordID]()
    var privateDatabase: CKDatabase!

    func execute(records: [CKRecord]) -> Promise<Bool> {
        return Promise {
            fulfill, reject in
            guard records.count > 0 else {
                fulfill(true)
                return
            }

            self.privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
            self.allRecords = self.getRecordsIDs(records)
            self.allBatchedRecords = self.allRecords.splitBy(batchSize)
            self.deleteBatch().then {
                success in
                fulfill(success)
            }.error(policy: .AllErrors) {
                error in
                reject(error)
            }
        }

    }

    private func deleteBatch() -> Promise<Bool> {
        return Promise {
            fulfill, reject in

            let uploadOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: self.allBatchedRecords[0])

            uploadOperation.atomic = false
            uploadOperation.database = privateDatabase

            uploadOperation.modifyRecordsCompletionBlock = {
                (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: NSError?) -> Void in
                self.removeDeletedElements(deletedRecords)
                if let error = operationError {
                    switch error.code {
                    case CKErrorCode.LimitExceeded.rawValue:
                        print("Limit exceeded")
                        self.rebatch()
                        break
                    default:
                        break
                    }

                    if self.retryDeleting() {
                        self.deleteBatch().then {
                            success in
                            fulfill(success)
                        }.error(policy:.AllErrors){
                            error in
                            reject(error)
                        }
                    }

                    print(error)
                    return
                }

                self.retryTimes = 0

                if self.allBatchedRecords.count == 0 {
                    fulfill(true)
                    return
                }

                if self.retryDeleting() {
                    self.deleteBatch().then {
                        success in
                        fulfill(success)
                    }.error(policy:.AllErrors){
                        error in
                        reject(error)
                    }
                }
            }

            NSOperationQueue().addOperation(uploadOperation)

        }
    }

    private func getRecordsIDs(records: [CKRecord]) -> [CKRecordID] {
        var recordsID = [CKRecordID]()
        for record: CKRecord in records {
            recordsID.append(record.recordID)
        }
        return recordsID
    }

    private func removeDeletedElements(deletedRecords: [CKRecordID]?) {
        if deletedRecords != nil && deletedRecords!.count > 0 {
            for record: CKRecordID in deletedRecords! {
                if self.allBatchedRecords[0].contains(record) {
                    self.allBatchedRecords[0].removeAtIndex(self.allBatchedRecords[0].indexOf(record)!)
                }
            }
        }
        if self.allBatchedRecords[0].count == 0 {
            self.allBatchedRecords.removeAtIndex(0)
        }
    }

    private func rebatch() {
        self.batchSize = Int(self.batchSize / 2)
        var recordsToDelete = [CKRecordID]()
        for recordsBatch in self.allBatchedRecords {
            for record in recordsBatch {
                recordsToDelete.append(record)
            }
        }

        self.allBatchedRecords = recordsToDelete.splitBy(self.batchSize)
    }

    private func retryDeleting() -> Bool {
        self.retryTimes = self.retryTimes + 1
        if self.retryTimes == self.maxRetryTimes {
            return false
        }
        return true
    }

}
