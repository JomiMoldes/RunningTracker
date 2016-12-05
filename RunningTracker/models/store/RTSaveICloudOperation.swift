//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTSaveICloudOperation {

    let maxRetryTimes = 3
    var batchSize = 400
    var allBatchedRecords = [[CKRecord]]()
    var allSavedRecords = [CKRecord]()
    var allRecords = [CKRecord]()
    var retryTimes = 0
    var privateDatabase:CKDatabase!

    func execute(_ records:[CKRecord]) -> Promise<Bool> {
        return Promise {
            fulfill, reject in

            guard records.count > 0 else {
                fulfill(true)
                return
            }

            self.allRecords = records
            self.allBatchedRecords = records.splitBy(batchSize)
            privateDatabase = CKContainer.default().privateCloudDatabase

            saveBatch().then {
                success in
                fulfill(success)
            }.catch(policy:.allErrors){
                error in
                fulfill(false)
            }

        }
    }

    fileprivate func saveBatch() -> Promise<Bool> {
        return Promise {
            fulfill, reject in

            let uploadOperation = CKModifyRecordsOperation(recordsToSave: self.allBatchedRecords[0], recordIDsToDelete: nil)
//            uploadOperation.atomic = false
            uploadOperation.database = privateDatabase
            uploadOperation.qualityOfService = .userInitiated

            uploadOperation.modifyRecordsCompletionBlock = {
                (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
                self.removeSavedElements(savedRecords)
                if let error = operationError {

                    switch error {
                    case CKError.limitExceeded:
                        self.rebatch()
                        self.retrySaving().then{
                            success in
                            fulfill(true)
                        }.catch(policy:.allErrors){
                            error in
                            reject(error)
                            return
                        }
                        break
                    default:
                        self.retrySaving().then{
                            success in
                            fulfill(true)
                        }.catch(policy:.allErrors){
                            error in
                            reject(error)
                            return
                        }
                        break
                    }

                    return
                }

                self.retryTimes = 0

                if self.allBatchedRecords.count == 0 {
                    fulfill(true)
                    return
                }
                self.saveBatch().then {
                    success in
                    fulfill(true)
                }.catch(policy:.allErrors){
                    error in
                    reject(error)
                    return
                }
            }

            OperationQueue().addOperation(uploadOperation)
        }

    }

    fileprivate func removeSavedElements(_ savedRecords: [CKRecord]?) {
        if savedRecords != nil && savedRecords!.count > 0 {
            for record : CKRecord in savedRecords! {
                if self.allBatchedRecords[0].contains(record) {
                    self.allBatchedRecords[0].remove(at: self.allBatchedRecords[0].index(of: record)!)
                }
                allSavedRecords.append(record)
            }
        }
        if self.allBatchedRecords[0].count == 0 {
            self.allBatchedRecords.remove(at: 0)
        }
    }

    fileprivate func rebatch(){
        self.batchSize = self.batchSize >= 200 ? self.batchSize - 100 : self.batchSize
        var recordsToSave = [CKRecord]()
        for recordsBatch in self.allBatchedRecords {
            for record in recordsBatch {
                recordsToSave.append(record)
            }
        }

        self.allBatchedRecords = recordsToSave.splitBy(self.batchSize)
    }

    fileprivate func retrySaving() -> Promise<Bool> {
        self.retryTimes = self.retryTimes + 1
        if self.retryTimes == self.maxRetryTimes {

            return Promise {
                fulfill, reject in
                self.rollback().then{
                    success in
                    fulfill(true)
                }.catch(policy:.allErrors){
                    error in
                    fulfill(false)
                }
            }
        }
        return self.saveBatch()
    }

    fileprivate func rollback() -> Promise<Bool> {
        return RTDeleteActivityICloudOperation().execute(self.allSavedRecords)
    }

}
