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

    func execute(_ records: [CKRecord]) -> Promise<Bool> {
        return Promise {
            fulfill, reject in
            guard records.count > 0 else {
                fulfill(true)
                return
            }

            self.privateDatabase = CKContainer.default().privateCloudDatabase
            self.allRecords = self.getRecordsIDs(records)
            self.allBatchedRecords = self.allRecords.splitBy(batchSize)
            self.deleteBatch().then {
                success in
                fulfill(success)
            }.catch(policy: .allErrors) {
                error in
                reject(error)
            }
        }

    }

    fileprivate func deleteBatch() -> Promise<Bool> {
        return Promise {
            fulfill, reject in

            let uploadOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: self.allBatchedRecords[0])

//            uploadOperation.atomic = false
            uploadOperation.database = privateDatabase
            uploadOperation.qualityOfService = .userInitiated

            uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
                self.removeDeletedElements(deletedRecords)
                if let error = operationError {
                    switch error {
                    case CKError.limitExceeded:
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
                        }.catch(policy:.allErrors){
                            error in
                            reject(error)
                        }
                    }else{
                        reject(error)
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
                    }.catch(policy:.allErrors){
                        error in
                        reject(error)
                    }
                }
            }

            OperationQueue().addOperation(uploadOperation)

        }
    }

    fileprivate func getRecordsIDs(_ records: [CKRecord]) -> [CKRecordID] {
        var recordsID = [CKRecordID]()
        for record: CKRecord in records {
            recordsID.append(record.recordID)
        }
        return recordsID
    }

    fileprivate func removeDeletedElements(_ deletedRecords: [CKRecordID]?) {
        if deletedRecords != nil && deletedRecords!.count > 0 {
            for record: CKRecordID in deletedRecords! {
                if self.allBatchedRecords[0].contains(record) {
                    self.allBatchedRecords[0].remove(at: self.allBatchedRecords[0].index(of: record)!)
                }
            }
        }
        if self.allBatchedRecords[0].count == 0 {
            self.allBatchedRecords.remove(at: 0)
        }
    }

    fileprivate func rebatch() {
        self.batchSize = Int(self.batchSize / 2)
        var recordsToDelete = [CKRecordID]()
        for recordsBatch in self.allBatchedRecords {
            for record in recordsBatch {
                recordsToDelete.append(record)
            }
        }

        self.allBatchedRecords = recordsToDelete.splitBy(self.batchSize)
    }

    fileprivate func retryDeleting() -> Bool {
        self.retryTimes = self.retryTimes + 1
        if self.retryTimes == self.maxRetryTimes {
            return false
        }
        return true
    }

}
