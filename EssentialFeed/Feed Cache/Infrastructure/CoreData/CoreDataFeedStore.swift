//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by DHIKA ADITYA ARE on 18/06/26.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(
        storeURL: URL,
        bundle: Bundle = .main
    ) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    /// Mengambil feed yang di-cache dari penyimpanan Core Data secara asinkron.
    ///
    /// Metode ini melakukan fetch pada `NSManagedObjectContext` latar belakang untuk memuat
    /// entitas `ManagedCache` beserta objek `ManagedFeedImage` yang terkait. Lalu,
    /// objek-objek terkelola tersebut dipetakan menjadi model `LocalFeedImage` dan hasilnya
    /// dikembalikan melalui completion handler yang disediakan.
    ///
    /// Perilaku:
    /// - Jika cache ada, akan menyelesaikan dengan `.found(feed: [LocalFeedImage], timestamp: Date)`.
    /// - Jika tidak ada cache, akan menyelesaikan dengan `.empty`.
    /// - Jika terjadi kesalahan saat fetch atau pemetaan, akan menyelesaikan dengan `.failure(Error)`.
    ///
    /// Threading:
    /// - Proses fetch dan pemetaan dijalankan pada context latar belakang milik store dengan
    ///   menggunakan `perform` untuk memastikan thread-safety.
    /// - Completion handler akan dipanggil pada antrian context latar belakang; pemanggil
    ///   sebaiknya melakukan dispatch ke antrian yang diinginkan bila perlu.
    ///
    /// - Parameter completion: Closure yang dipanggil dengan hasil pengambilan data. Lihat `RetrieveCompletion` untuk detailnya.
    ///
    /// Prasyarat:
    /// - Mengasumsikan model Core Data berisi entitas `ManagedCache` dan `ManagedFeedImage`
    ///   yang dikonfigurasi untuk merepresentasikan feed yang di-cache dan gambar-gambarnya.
    /// - Persistent container harus berhasil dimuat saat inisialisasi store.
    public func retrieve(completion: @escaping RetrieveCompletion) {
        // completion(.empty)
//        let context = self.context
//        context.perform {
        perform { context in
            do {
                /*
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                */
                if let cache = try ManagedCache.find(in: context) {
                    /*
                    completion(.found(
                        feed: cache.feed
                            .compactMap { ($0 as? ManagedFeedImage) }
                            .map {
                                LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)
                            },
                        timestamp: cache.timestamp))
                    */
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    

    /// Menyisipkan item feed ke dalam penyimpanan Core Data dengan cap waktu terkait.
    ///
    /// Operasi dilakukan secara asinkron pada `NSManagedObjectContext` latar belakang milik store
    /// menggunakan `perform` untuk menjaga keselamatan thread. Metode ini membuat `ManagedCache` baru,
    /// memetakan setiap `LocalFeedImage` menjadi `ManagedFeedImage`, lalu menyimpan konteks.
    ///
    /// Perilaku:
    /// - Jika berhasil, perubahan akan dipersistenkan dan `completion(nil)` dipanggil.
    /// - Jika gagal (mis. validasi, pemetaan, atau saat menyimpan), `completion(error)` dipanggil dengan error yang terjadi.
    ///
    /// Threading:
    /// - Seluruh pekerjaan Core Data dijalankan pada antrian konteks latar belakang.
    /// - Closure `completion` juga dipanggil pada antrian yang sama; lakukan dispatch ke antrian lain jika diperlukan.
    ///
    /// Persistensi:
    /// - Metode ini membuat instance cache baru dan menetapkan kumpulan berurutan (`NSOrderedSet`)
    ///   dari gambar yang dikelola sesuai urutan `feed` yang diberikan. Kebijakan penggantian/
    ///   pembersihan cache yang sudah ada sebaiknya ditangani oleh pemanggil atau bagian lain dari store.
    ///
    /// - Parameter:
    ///   - feed: Array `LocalFeedImage` yang akan disimpan.
    ///   - timestamp: Tanggal yang terkait dengan feed untuk keperluan validasi usia cache.
    ///   - completion: Closure yang dipanggil saat operasi selesai, `nil` jika sukses atau `Error` jika gagal.
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
//        let context = self.context
//        context.perform {
        perform { context in
            do {
                // let managedCache = ManagedCache(context: context)
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                /*
                managedCache.feed = NSOrderedSet(array: feed.map { local in
                    let managed = ManagedFeedImage(context: context)
                    managed.id = local.id
                    managed.imageDescription = local.description
                    managed.location = local.location
                    managed.url = local.url
                    return managed
                })
                */
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        // completion(nil)
//        let context = self.context
//        context.perform {
        perform { context in
            do {
                try ManagedCache.find(in: context)
                    .map(context.delete)
                    .map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
