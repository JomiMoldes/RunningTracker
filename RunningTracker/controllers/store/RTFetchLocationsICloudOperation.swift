//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTFetchLocationsICloudOperation {

    var locationsRecords = [CKRecord]()
    var database: CKDatabase!

    func execute(activitiesRecordsIds: [Int]) -> Promise<[CKRecord]> {
        database = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(format: "activityid IN %@", activitiesRecordsIds)
        let query = CKQuery(recordType: "Locations2", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

        return Promise {
            fulfill, reject in

            guard activitiesRecordsIds.count > 0 else {
                fulfill([CKRecord]())
                return
            }

            fetchRecordsWithQuery(queryOperation).then {
                records in
                fulfill(records)
            }.error(policy: .AllErrors) {
                error in
                fulfill([CKRecord]())
            }
        }
    }

    private func fetchRecordsWithQuery(query: CKQueryOperation) -> Promise<[CKRecord]> {
        return Promise {
            fulfill, reject in

            let queryOperation = query
            queryOperation.qualityOfService = .UserInitiated
            queryOperation.recordFetchedBlock = fetchedLocationsRecord

            queryOperation.queryCompletionBlock = {
                cursor, error in

                guard error == nil else {
                    reject(error!)
                    return
                }

                guard let cursor = cursor else {
                    fulfill(self.locationsRecords)
                    return
                }

                let queryOperation = CKQueryOperation(cursor: cursor)
                self.fetchRecordsWithQuery(queryOperation).then {
                    locations in
                    fulfill(locations)
                }.error(policy: .AllErrors) {
                    error in
                    reject(error)
                }

            }
            self.database.addOperation(queryOperation)
        }

    }

    func fetchedLocationsRecord(record: CKRecord!) {
        locationsRecords.append(record)
    }

}
