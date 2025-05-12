import SwiftUI


// MARK: - Data Models
struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let category: String
    var isCustom: Bool = false
}

// MARK: - Cart Manager
class CartManager: ObservableObject {
    @Published var cartItems: [Product: Int] = [:]
    @Published var boughtItems: [Product: Int] = [:]
    
    var totalItems: Int {
        cartItems.values.reduce(0, +) + boughtItems.values.reduce(0, +)
    }
    
    func add(_ product: Product) {
        if boughtItems[product] != nil {
            boughtItems[product] = nil
        }
        cartItems[product, default: 0] += 1
    }
    
    func remove(_ product: Product) {
        if let count = cartItems[product], count > 0 {
            cartItems[product] = count - 1
            if cartItems[product] == 0 {
                cartItems[product] = nil
            }
        } else if let count = boughtItems[product], count > 0 {
            boughtItems[product] = count - 1
            if boughtItems[product] == 0 {
                boughtItems[product] = nil
            }
        }
    }
    
    func delete(_ product: Product) {
        cartItems[product] = nil
        boughtItems[product] = nil
    }
    
    func clearCart() {
        cartItems.removeAll()
        boughtItems.removeAll()
    }
    
    func addCustomProduct(name: String, count: Int) {
        let customProduct = Product(
            name: name,
            icon: "cart.badge.plus",
            description: "Добавлено вручную",
            category: "Пользовательские",
            isCustom: true
        )
        cartItems[customProduct] = count
    }
    
    func updateProductCount(_ product: Product, count: Int) {
        if count > 0 {
            if boughtItems[product] != nil {
                boughtItems[product] = nil
                cartItems[product] = count
            } else {
                cartItems[product] = count
            }
        } else {
            cartItems[product] = nil
            boughtItems[product] = nil
        }
    }
    
    func markAsBought(_ product: Product) {
        if let count = cartItems[product] {
            cartItems[product] = nil
            boughtItems[product] = count
        }
    }
    
    func markAsNotBought(_ product: Product) {
        if let count = boughtItems[product] {
            boughtItems[product] = nil
            cartItems[product] = count
        }
    }
}

// MARK: - App Theme
struct AppTheme {
    static let primary = Color(red: 0.18, green: 0.57, blue: 0.84)
    static let secondary = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let accent = Color(red: 0.97, green: 0.48, blue: 0.42)
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.55)
    
    static let backgroundGradient = AngularGradient(
        gradient: Gradient(colors: [
            Color(red: 0.93, green: 0.95, blue: 1.0),
            Color(red: 0.98, green: 0.96, blue: 0.93),
            Color(red: 0.95, green: 0.98, blue: 0.96),
            Color(red: 0.93, green: 0.95, blue: 1.0)
        ]),
        center: .center,
        angle: .degrees(45)
    )
    
    static let categoryGradient = LinearGradient(
        gradient: Gradient(colors: [primary, primary.opacity(0.7)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let unselectedCategoryGradient = LinearGradient(
        gradient: Gradient(colors: [secondary.opacity(0.9), secondary.opacity(0.9)]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var cart = CartManager()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showingAddCustomItem = false
    @State private var backgroundAngle: Double = 0
    
    let products: [Product] = [
        // Dairy
        Product(name: "Молоко", icon: "drop.fill", description: "1 литр свежее молоко 2.5%", category: "Молочные"),
        Product(name: "Сыр Российский", icon: "rectangle.fill", description: "Российский сыр 200г", category: "Молочные"),
        Product(name: "Творог", icon: "square.fill", description: "Творог 5% 200г", category: "Молочные"),
        Product(name: "Сметана", icon: "circle.fill", description: "Сметана 15% 200г", category: "Молочные"),
        Product(name: "Йогурт", icon: "cup.and.saucer.fill", description: "Йогурт фруктовый 150г", category: "Молочные"),
        Product(name: "Кефир", icon: "drop.fill", description: "Кефир 2.5% 1л", category: "Молочные"),
        Product(name: "Масло сливочное", icon: "square.fill", description: "Масло сливочное 82.5% 180г", category: "Молочные"),
        
        // Bakery
        Product(name: "Хлеб белый", icon: "rectangle.roundedtop.fill", description: "Хлеб пшеничный 300г", category: "Хлебобулочные"),
        Product(name: "Батон", icon: "rectangle.split.2x1.fill", description: "Батон нарезной 300г", category: "Хлебобулочные"),
        Product(name: "Багет", icon: "rectangle.split.1x2.fill", description: "Багет французский 250г", category: "Хлебобулочные"),
        Product(name: "Булочки", icon: "circle.grid.2x2.fill", description: "Булочки с маком 4шт", category: "Хлебобулочные"),
        Product(name: "Лаваш", icon: "rectangle.fill", description: "Лаваш армянский 200г", category: "Хлебобулочные"),
        Product(name: "Круассаны", icon: "croissant.fill", description: "Круассаны с шоколадом 4шт", category: "Хлебобулочные"),
        
        // Fruits and Vegetables
        Product(name: "Яблоки", icon: "circle.fill", description: "Яблоки Голден 1кг", category: "Фрукты и овощи"),
        Product(name: "Бананы", icon: "moon.fill", description: "Бананы 1кг", category: "Фрукты и овощи"),
        Product(name: "Огурцы", icon: "capsule.fill", description: "Огурцы свежие 500г", category: "Фрукты и овощи"),
        Product(name: "Помидоры", icon: "circle.fill", description: "Помидоры 500г", category: "Фрукты и овощи"),
        Product(name: "Картофель", icon: "oval.fill", description: "Картофель молодой 1кг", category: "Фрукты и овощи"),
        Product(name: "Морковь", icon: "carrot.fill", description: "Морковь свежая 1кг", category: "Фрукты и овощи"),
        Product(name: "Апельсины", icon: "circle.fill", description: "Апельсины 1кг", category: "Фрукты и овощи"),
        Product(name: "Лук репчатый", icon: "onion.fill", description: "Лук репчатый 1кг", category: "Фрукты и овощи"),
        
        // Meat and Fish
        Product(name: "Куриное филе", icon: "rectangle.fill", description: "Филе куриное охлажденное 500г", category: "Мясо и рыба"),
        Product(name: "Фарш говяжий", icon: "square.fill", description: "Фарш говяжий 400г", category: "Мясо и рыба"),
        Product(name: "Свинина", icon: "rectangle.on.rectangle.fill", description: "Свинина для жарки 500г", category: "Мясо и рыба"),
        Product(name: "Сёмга", icon: "seal.fill", description: "Филе сёмги 300г", category: "Мясо и рыба"),
        Product(name: "Колбаса вареная", icon: "rectangle.fill", description: "Колбаса докторская 400г", category: "Мясо и рыба"),
        Product(name: "Креветки", icon: "shrimp.fill", description: "Креветки очищенные 300г", category: "Мясо и рыба"),
        
        // Household Goods
        Product(name: "Мыло", icon: "square.fill", description: "Хозяйственное мыло 100г", category: "Хоз товары"),
        Product(name: "Шампунь", icon: "drop.fill", description: "Шампунь для всех типов волос 250мл", category: "Хоз товары"),
        Product(name: "Зубная паста", icon: "capsule.fill", description: "Зубная паста комплексная защита 100мл", category: "Хоз товары"),
        Product(name: "Гель для душа", icon: "drop.fill", description: "Гель для душа увлажняющий 250мл", category: "Хоз товары"),
        Product(name: "Губки для посуды", icon: "square.stack.fill", description: "Губки для мытья посуды 5шт", category: "Хоз товары"),
        Product(name: "Стиральный порошок", icon: "sparkles", description: "Порошок универсальный 1кг", category: "Хоз товары")
    ]
    
    var categories: [String] {
        Array(Set(products.map { $0.category })).sorted()
    }
    
    var filteredProducts: [Product] {
        var result = products
        if let selectedCategory = selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
        return result
    }
    
    var groupedProducts: [String: [Product]] {
        Dictionary(grouping: filteredProducts) { $0.category }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                    .rotationEffect(.degrees(backgroundAngle))
                    .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: backgroundAngle)
                    .onAppear {
                        backgroundAngle = 360
                    }
                
                VStack(spacing: 0) {
                    SearchBarView(searchText: $searchText)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    CategorySelectorView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                    .padding(.vertical, 10)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(groupedProducts.keys.sorted(), id: \.self) { category in
                                VStack(alignment: .leading) {
                                    Text(category)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 16) {
                                            ForEach(groupedProducts[category]!) { product in
                                                ProductCardView(product: product, cart: cart)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 4)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 80)
                    }
                }
                .navigationTitle("Мой Список Покупок")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CartView().environmentObject(cart)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.primary)
                                if cart.totalItems > 0 {
                                    Text("\(cart.totalItems)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(AppTheme.accent)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingAddCustomItem = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCustomItem) {
            AddCustomItemView(cart: cart, isPresented: $showingAddCustomItem)
        }
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            TextField("Поиск продуктов", text: $searchText)
                .foregroundColor(AppTheme.textPrimary)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondary.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Category Selector View
struct CategorySelectorView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { selectedCategory = nil }) {
                    Text("Все")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            selectedCategory == nil ?
                            AppTheme.categoryGradient :
                            AppTheme.unselectedCategoryGradient
                        )
                        .foregroundColor(selectedCategory == nil ? .white : AppTheme.textPrimary)
                        .cornerRadius(20)
                        .shadow(color: selectedCategory == nil ? AppTheme.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                }
                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category)
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category ?
                                AppTheme.categoryGradient :
                                AppTheme.unselectedCategoryGradient
                            )
                            .foregroundColor(selectedCategory == category ? .white : AppTheme.textPrimary)
                            .cornerRadius(20)
                            .shadow(color: selectedCategory == category ? AppTheme.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Add Custom Item View
struct AddCustomItemView: View {
    @ObservedObject var cart: CartManager
    @Binding var isPresented: Bool
    @State private var productName = ""
    @State private var quantity = 1
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Добавить свой товар")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название товара")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        TextField("Введите название", text: $productName)
                            .padding()
                            .background(AppTheme.secondary.opacity(0.9))
                            .cornerRadius(12)
                            .focused($isNameFocused)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Количество")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        HStack {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Text("\(quantity)")
                                .font(.title)
                                .frame(width: 60)
                                .foregroundColor(AppTheme.textPrimary)
                            Button(action: { quantity += 1 }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        .padding()
                        .background(AppTheme.secondary.opacity(0.9))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        if !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            cart.addCustomProduct(name: productName, count: quantity)
                            isPresented = false
                        }
                    }) {
                        Text("Добавить в список")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .background(
                                AppTheme.categoryGradient
                            )
                            .cornerRadius(16)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                            .opacity(productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.bottom)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isNameFocused = true
                    }
                }
            }
            .navigationBarItems(trailing: Button("Отмена") {
                isPresented = false
            }.foregroundColor(AppTheme.primary))
        }
    }
}

// MARK: - Product Card View
struct ProductCardView: View {
    let product: Product
    @ObservedObject var cart: CartManager
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product).environmentObject(cart)) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: product.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding()
                        .foregroundColor(AppTheme.primary)
                    if let count = cart.cartItems[product] ?? cart.boughtItems[product], count > 0 {
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(AppTheme.accent)
                            .clipShape(Circle())
                            .padding(6)
                    }
                }
                .frame(width: 120, height: 120)
                .background(AppTheme.secondary.opacity(0.9))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    Text(product.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: 120)
                
                Button(action: { cart.add(product) }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("В список")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .frame(width: 120)
                    .background(AppTheme.categoryGradient)
                    .cornerRadius(8)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
            .padding(8)
            .background(Color.white.opacity(0.95))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Product Detail View
struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity: Int = 1
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppTheme.secondary.opacity(0.9))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        Image(systemName: product.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(AppTheme.primary)
                    }
                    .frame(height: 220)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(product.category)
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.top, 8)
                        
                        Divider().padding(.vertical, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Количество")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textPrimary)
                            HStack(spacing: 20) {
                                Button(action: { if quantity > 0 { quantity -= 1 } }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(AppTheme.primary)
                                        .cornerRadius(18)
                                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                                Text("\(quantity)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(minWidth: 40)
                                Button(action: { quantity += 1 }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(AppTheme.primary)
                                        .cornerRadius(18)
                                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if let existingCount = cart.cartItems[product], existingCount > 0 {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("В списке: \(existingCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 8)
                        } else if let existingCount = cart.boughtItems[product], existingCount > 0 {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Куплено: \(existingCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CartView().environmentObject(cart)) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(AppTheme.primary)
                            if cart.totalItems > 0 {
                                Text("\(cart.totalItems)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(AppTheme.accent)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        cart.updateProductCount(product, count: quantity)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Добавить в список")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.categoryGradient)
                            .cornerRadius(16)
                            .padding()
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom)
                }
            )
        }
        .onAppear {
            if let existingCount = cart.cartItems[product] ?? cart.boughtItems[product] {
                quantity = existingCount
            }
        }
    }
}

// MARK: - Cart Item Detail View
struct CartItemDetailView: View {
    let product: Product
    @EnvironmentObject var cart: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity: Int
    
    init(product: Product, initialQuantity: Int) {
        self.product = product
        self._quantity = State(initialValue: initialQuantity)
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: product.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(AppTheme.primary)
                        .padding()
                        .background(AppTheme.secondary.opacity(0.9))
                        .cornerRadius(12)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Количество")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    HStack(spacing: 20) {
                        Button(action: { if quantity > 0 { quantity -= 1 } }) {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(AppTheme.primary)
                                .cornerRadius(18)
                        }
                        Text("\(quantity)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(minWidth: 40)
                        Button(action: { quantity += 1 }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(AppTheme.primary)
                                .cornerRadius(18)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                
                if cart.cartItems[product] != nil {
                    Button(action: { cart.markAsBought(product) }) {
                        Text("Переместить в куплено")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                } else if cart.boughtItems[product] != nil {
                    Button(action: { cart.markAsNotBought(product) }) {
                        Text("Вернуть в список")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.primary)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                
                Button(action: { cart.delete(product); presentationMode.wrappedValue.dismiss() }) {
                    Text("Удалить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    cart.updateProductCount(product, count: quantity)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.categoryGradient)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .padding(.top)
            .navigationTitle("Редактировать товар")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Cart View
struct CartView: View {
    @EnvironmentObject var cart: CartManager
    @State private var showingAddCustomItem = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                if cart.cartItems.isEmpty && cart.boughtItems.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "cart.badge.minus")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Ваш список пуст")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Добавьте продукты из каталога или создайте свои")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button(action: { showingAddCustomItem = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Добавить свой товар")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.primary)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                } else {
                    List {
                        // To Buy Section
                        if !cart.cartItems.isEmpty {
                            Section(header: Text("К покупке").font(.headline)) {
                                ForEach(cart.cartItems.keys.sorted(by: { $0.name < $1.name }), id: \.self) { product in
                                    NavigationLink(destination: CartItemDetailView(product: product, initialQuantity: cart.cartItems[product] ?? 1)) {
                                        HStack(spacing: 12) {
                                            Image(systemName: product.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(AppTheme.primary)
                                                .padding(6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(AppTheme.secondary.opacity(0.9))
                                                )
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(product.name)
                                                    .font(.headline)
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text(product.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.textSecondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            Text("\(cart.cartItems[product] ?? 0)")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.textPrimary)
                                                .frame(width: 30, alignment: .center)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(action: { cart.markAsBought(product) }) {
                                            Label("Куплено", systemImage: "checkmark.circle")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive, action: { cart.delete(product) }) {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Bought Section
                        if !cart.boughtItems.isEmpty {
                            Section(header: Text("Куплено").font(.headline)) {
                                ForEach(cart.boughtItems.keys.sorted(by: { $0.name < $1.name }), id: \.self) { product in
                                    NavigationLink(destination: CartItemDetailView(product: product, initialQuantity: cart.boughtItems[product] ?? 1)) {
                                        HStack(spacing: 12) {
                                            Image(systemName: product.icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(AppTheme.primary.opacity(0.5))
                                                .padding(6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(AppTheme.secondary.opacity(0.5))
                                                )
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(product.name)
                                                    .font(.headline)
                                                    .foregroundColor(AppTheme.textPrimary.opacity(0.5))
                                                    .strikethrough()
                                                Text(product.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                                                    .lineLimit(1)
                                                    .strikethrough()
                                            }
                                            Spacer()
                                            Text("\(cart.boughtItems[product] ?? 0)")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.textPrimary.opacity(0.5))
                                                .frame(width: 30, alignment: .center)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(action: { cart.markAsNotBought(product) }) {
                                            Label("Не куплено", systemImage: "arrow.uturn.left.circle")
                                        }
                                        .tint(.blue)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive, action: { cart.delete(product) }) {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    Button(action: { cart.clearCart() }) {
                        Text("Очистить список")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Список покупок")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCustomItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddCustomItem) {
                AddCustomItemView(cart: cart, isPresented: $showingAddCustomItem)
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
