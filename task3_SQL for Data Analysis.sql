-- Top 5 Most Expensive Order Items for a Specific Seller
SELECT order_id, product_id, price
FROM order_items
WHERE seller_id = '48436dade18ac8b2bce089ec2a041202'
ORDER BY price DESC
LIMIT 5;

-- Total Revenue per Product Category
SELECT pct.product_category_name_english AS category,
       SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY total_revenue DESC;

-- Average Review Score by State (Customer State)
SELECT c.customer_state, 
       ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;

-- Top Customer States by Total Number of Orders (with WHERE filter)
SELECT c.customer_state, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING total_orders > 100
ORDER BY total_orders DESC;

-- Total Payment Value by Payment Type
SELECT payment_type, 
       COUNT(*) AS transaction_count,
       SUM(payment_value) AS total_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;

-- Create a View: Category-wise Sales
CREATE VIEW category_sales AS
SELECT pct.product_category_name_english AS category,
       SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english;
SELECT * FROM category_sales;

-- Subquery: Orders Above Average Payment
SELECT order_id, payment_value
FROM order_payments
WHERE payment_value > (
    SELECT AVG(payment_value) FROM order_payments
);

-- Index to speed up seller_id filtering
CREATE INDEX IF NOT EXISTS idx_order_items_seller_id 
ON order_items (seller_id);

-- Index for filtering by order date
CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp 
ON orders (order_purchase_timestamp);

-- Index for comparing payment values
CREATE INDEX IF NOT EXISTS idx_order_payments_value 
ON order_payments (payment_value);

-- Index for aggregating review scores
CREATE INDEX IF NOT EXISTS idx_order_reviews_score 
ON order_reviews (review_score);

-- Index for joining by product category
CREATE INDEX IF NOT EXISTS idx_products_category_name 
ON products (product_category_name);

