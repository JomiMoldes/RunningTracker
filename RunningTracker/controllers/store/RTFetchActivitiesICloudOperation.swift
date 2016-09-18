//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTFetchActivitiesICloudOperation {

    var activitiesRecords = [CKRecord]()
    var database:CKDatabase!

    func execute() -> Promise <[CKRecord]> {
        database = CKContainer.defaultContainer().privateCloudDatabase
        let query = CKQuery(recordType: "Activities2", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let queryOperation = CKQueryOperation(query: query)
        return fetchRecordsWithQuery(queryOperation)
    }

    private func fetchRecordsWithQuery(query:CKQueryOperation) -> Promise<[CKRecord]> {
        return Promise {
            fulfill, reject in

            let queryOperation = query
            queryOperation.qualityOfService = .UserInitiated
            queryOperation.recordFetchedBlock = fetchedActivitiesRecord

            queryOperation.queryCompletionBlock = {
                cursor, error in

                guard error == nil else {
                    reject(error!)
                    return
                }

                guard let cursor = cursor else {
                    fulfill(self.activitiesRecords)
                    return
                }

                let queryOperation = CKQueryOperation(cursor: cursor)
                self.fetchRecordsWithQuery(queryOperation).then {
                    activities in
                    fulfill(activities)
                }.error(policy:.AllErrors){
                    error in
                    reject(error)
                }

            }
            self.database.addOperation(queryOperation)
        }

    }

    func fetchedActivitiesRecord(record: CKRecord!) {
        self.activitiesRecords.append(record)
    }

}
