//
//  GraphQLZero.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//
//  swiftlint:disable missing_docs
//  swiftlint:disable redundant_optional_initialization
//  swiftlint:disable discouraged_optional_collection
//  swiftlint:disable discouraged_optional_boolean
//  swiftlint:disable identifier_name
//  swiftlint:disable file_length

import Foundation
import GraphQLKit
import GraphQLKitMacros
import SwiftyJSON

/*
All of the objects and queries as well as a mutation for the GraphQLZero API:
https://graphqlzero.almansi.me
*/
enum GraphQLZero { }

@GraphQLQuery
struct Albums {

    static var query: String { "albums" }
    var options: PageQueryOptions
    var fields: AlbumsPage.Fields

}

@GraphQLQuery
struct AlbumQuery {

    static var query: String { "album" }
    var id: String
    var fields: Album.Fields

}

@GraphQLQuery
struct Comments {

    static var query: String { "comments" }
    var options: PageQueryOptions
    var fields: CommentsPage.Fields

}

@GraphQLQuery
struct CommentQuery {

    static var query: String { "comment" }
    var id: String
    var fields: Comment.Fields

}

@GraphQLQuery
struct Photos {

    static var query: String { "photos" }
    var options: PageQueryOptions
    var fields: PhotosPage.Fields

}

@GraphQLQuery
struct PhotoQuery {

    static var query: String { "photo" }
    var id: String
    var fields: Photo.Fields

}

@GraphQLQuery
struct Posts {

    static var query: String { "posts" }
    var options: PageQueryOptions
    var fields: PostsPage.Fields

}

@GraphQLQuery
struct PostQuery {

    static var query: String { "post" }
    var id: String
    var fields: Post.Fields

}

@GraphQLQuery
struct Todos {

    static var query: String { "todos" }
    var options: PageQueryOptions
    var fields: Post.Fields

}

@GraphQLQuery
struct TodoQuery {

    static var query: String { "todo" }
    var id: String
    var fields: Todo.Fields

}

@GraphQLQuery
struct Users {

    static var query: String { "users" }
    var options: PageQueryOptions
    var fields: UsersPage.Fields

}

@GraphQLQuery
struct UserQuery {

    static var query: String { "user" }
    var id: String
    var fields: User.Fields

}

@GraphQLMutation
struct CreateAlbum {

    static var query: String { "createAlbum" }
    var input: CreateAlbumInput
    var fields: Album.Fields

}

@GraphQLObject
final class PageQueryOptions {

    var paginate: PaginateOptions?
    var slice: SliceOptions?
    var sort: [SortOptions]?
    var operators: [OperatorOptions]?
    var search: SearchOptions?

    init() { }

}

@GraphQLObject
final class PaginateOptions {

    @Value var page: Int? = nil
    @Value var limit: Int? = nil

}

@GraphQLObject
final class SliceOptions {

    @Value var start: Int? = nil
    @Value var end: Int? = nil
    @Value var limit: Int? = nil

}

@GraphQLObject
final class SortOptions {

    @Value var field: String? = nil
    @Value var order: SortOrderEnum? = nil

}

@GraphQLObject
final class OperatorOptions {

    @Value var kind: OperatorKindEnum? = nil
    @Value var field: String? = nil
    @Value var value: String? = nil

}

@GraphQLObject
final class SearchOptions {

    @Value var q: String? = nil

}

@GraphQLObject
final class AlbumsPage {

    var data: [Album]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class Album {

    @Value var id: String? = nil
    @Value var title: String? = nil
    var user: User?
    @Arguments(["options": PageQueryOptions()])
    var photos: PhotosPage? = nil

}

@GraphQLObject
final class User {

    @Value var id: String? = nil
    @Value var name: String? = nil
    @Value var username: String? = nil
    @Value var email: String? = nil
    var address: Address?
    @Value var phone: String? = nil
    @Value var website: String? = nil
    var company: Company?
    @Arguments(["options": PageQueryOptions()])
    var posts: PostsPage? = nil
    @Arguments(["options": PageQueryOptions()])
    var albums: AlbumsPage? = nil
    @Arguments(["options": PageQueryOptions()])
    var todos: TodosPage? = nil

}

@GraphQLObject
final class Address {

    @Value var street: String? = nil
    @Value var suite: String? = nil
    @Value var city: String? = nil
    @Value var zipcode: String? = nil
    var geo: Geo?
    @Arguments(["options": PageQueryOptions()])
    var posts: PostsPage? = nil

}

@GraphQLObject
final class Geo {

    @Value var lat: Double? = nil
    @Value var lng: Double? = nil

}

@GraphQLObject
final class Company {

    @Value var name: String? = nil
    @Value var catchPhrase: String? = nil
    @Value var bs: String? = nil

}

@GraphQLObject
final class PostsPage {

    var data: [Post]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class Post {

    @Value var id: String? = nil
    @Value var title: String? = nil
    @Value var body: String? = nil
    var user: User?
    @Arguments(["options": PageQueryOptions()])
    var comments: CommentsPage? = nil

}

@GraphQLObject
final class CommentsPage {

    var data: [Comment]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class Comment {

    @Value var id: String? = nil
    @Value var name: String? = nil
    @Value var email: String? = nil
    @Value var body: String? = nil
    @Value var post: String? = nil

}

@GraphQLObject
final class PaginationLinks {

    var first: PageLimitPair?
    var prev: PageLimitPair?
    var next: PageLimitPair?
    var last: PageLimitPair?

}

@GraphQLObject
final class PageLimitPair {

    @Value var page: Int? = nil
    @Value var limt: Int? = nil

}

@GraphQLObject
final class PageMetadata {

    @Value var totalCount: Int? = nil

}

@GraphQLObject
final class TodosPage {

    var data: [Todo]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class Todo {

    @Value var id: String? = nil
    @Value var title: String? = nil
    @Value var completed: Bool? = nil
    var user: User?

}

@GraphQLObject
final class PhotosPage {

    var data: [Photo]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class Photo {

    @Value var id: String? = nil
    @Value var title: String? = nil
    @Value var url: String? = nil
    @Value var thumbnailUrl: String? = nil
    var album: Album?

}

@GraphQLObject
final class UsersPage {

    var data: [User]?
    var links: PaginationLinks?
    var meta: PageMetadata?

}

@GraphQLObject
final class CreateAlbumInput {

    @Value var title: String? = nil
    @Value var userId: String? = nil

}

enum SortOrderEnum: String, GraphQLValueType, Codable {

    case ASC
    case DESC

    var string: String {
        rawValue
    }

}

enum OperatorKindEnum: String, GraphQLValueType, Codable {

    case GTE
    case LTE
    case NE
    case LIKE

    var string: String {
        rawValue
    }

}

// swiftlint:enable missing_docs
// swiftlint:enable redundant_optional_initialization
// swiftlint:enable discouraged_optional_collection
// swiftlint:enable discouraged_optional_boolean
// swiftlint:enable identifier_name
// swiftlint:enable file_length
