# Lumenary Backend API 文档

## 项目概述

**项目名称**: Lumenary (Life Tracker API)
**技术栈**: FastAPI + SQLAlchemy (async) + PostgreSQL 16
**AI服务**: Google Gemini API
**Python**: 3.11+

---

## 本地开发

### 启动服务

```bash
cd /Users/apple/Documents/IOS/glimmer/server

# 启动所有服务
docker compose up -d

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f app

# 停止服务
docker compose down
```

### 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| API Server | http://localhost:8000 | FastAPI 后端 |
| API 文档 | http://localhost:8000/docs | Swagger UI |
| PostgreSQL | localhost:5433 | 数据库 |
| Mailpit UI | http://localhost:8025 | 邮件测试界面 |
| Mailpit SMTP | localhost:1025 | SMTP 服务 |

### 数据库迁移

```bash
# 生成迁移
docker compose run --rm app alembic revision --autogenerate -m "描述"

# 执行迁移
docker compose run --rm app alembic upgrade head

# 查看迁移历史
docker compose run --rm app alembic history
```

---

## 数据模型

### User (用户)
| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | UUID | 主键 |
| email | String | 唯一邮箱 |
| hashed_password | String | 密码哈希 |
| username | String | 用户名，默认 "momo" |
| timezone | String | IANA 时区标识符 |
| avatar_url | String | 头像 URL |

### Mood (心情记录)
| 字段 | 类型 | 说明 |
|------|------|------|
| mood_id | UUID | 主键 |
| user_id | UUID | 外键 → users |
| score | Integer | 心情分数 (1-15) |
| local_date | Date | 本地日期 |
| occurred_at_utc | DateTime | UTC 时间 |
| timezone_used | String | 使用的时区 |

**约束**: UNIQUE(user_id, local_date) - 每天只能记录一次

### CheckinRecord (签到记录)
| 字段 | 类型 | 说明 |
|------|------|------|
| checkin_id | UUID | 主键 |
| user_id | UUID | 外键 → users |
| local_date | Date | 本地日期 |
| timezone_used | String | 使用的时区 |

**约束**: UNIQUE(user_id, local_date) - 每天只能签到一次

### Journal (日志)
| 字段 | 类型 | 说明 |
|------|------|------|
| journal_id | UUID | 主键 |
| user_id | UUID | 外键 → users |
| title | String | 标题 (可选，≤120字) |
| content | Text | 内容 (必填，1-2000字) |
| local_date | Date | 本地日期 |
| occurred_at_utc | DateTime | UTC 时间 |

**关系**: 一对一关联 WarmMessageGroup

### EmergencyContact (紧急联系人)
| 字段 | 类型 | 说明 |
|------|------|------|
| contact_id | UUID | 主键 |
| user_id | UUID | 外键 → users (UNIQUE) |
| name | String | 联系人名字 |
| email | String | 联系人邮箱 |
| contact_relationship | String | 关系描述 (可选) |

### CheckinReminder (签到提醒)
| 字段 | 类型 | 说明 |
|------|------|------|
| reminder_id | UUID | 主键 |
| user_id | UUID | 外键 → users (UNIQUE) |
| enabled | Boolean | 是否启用 |
| time_local | String | HH:MM 格式的本地时间 |
| frequency_type | Enum | "daily" 或 "every_n_days" |
| interval_days | Integer | 间隔天数 (当 frequency_type="every_n_days" 时) |

### MissCheckinRule (缺失签到规则)
| 字段 | 类型 | 说明 |
|------|------|------|
| rule_id | UUID | 主键 |
| user_id | UUID | 外键 → users (UNIQUE) |
| threshold_days | Integer | 触发阈值 (默认 3 天) |
| message_template | String | 邮件模板 |

**模板占位符**: `{contact_name}`, `{username}`, `{interval_days}`

### PauseStatus (暂停状态)
| 字段 | 类型 | 说明 |
|------|------|------|
| pause_id | UUID | 主键 |
| user_id | UUID | 外键 → users (UNIQUE) |
| paused | Boolean | 是否暂停 |
| paused_at | DateTime | 暂停时间 (UTC) |

### WarmMessageGroup (温暖消息组)
| 字段 | 类型 | 说明 |
|------|------|------|
| group_id | UUID | 主键 |
| journal_id | UUID | 外键 → journals (UNIQUE) |
| generated_at | DateTime | 生成时间 |

### WarmMessage (温暖消息)
| 字段 | 类型 | 说明 |
|------|------|------|
| message_id | UUID | 主键 |
| journal_id | UUID | 外键 → journals |
| group_id | UUID | 外键 → warm_message_groups |
| content | String | 消息内容 (≤200字) |

---

## API 端点

**Base URL**: `/api/v1`

### 心情 (Moods)

| 方法 | 端点 | 功能 | 请求体 |
|------|------|------|--------|
| POST | `/moods` | 创建今日心情 | `{score: 1-15}` |
| GET | `/moods/today` | 获取今日心情 | - |
| GET | `/moods?from=YYYY-MM-DD&to=YYYY-MM-DD` | 获取日期范围心情 | - |

### 签到 (Checkins)

| 方法 | 端点 | 功能 | 请求体 |
|------|------|------|--------|
| POST | `/checkins` | 创建今日签到 | - |
| GET | `/checkins/today` | 获取今日签到状态 | - |

**注意**: 如果用户处于暂停状态，POST 请求返回 403

### 日志 (Journals)

| 方法 | 端点 | 功能 | 请求体 |
|------|------|------|--------|
| POST | `/journals` | 创建日志 | `{title?: str, content: str}` |
| GET | `/journals/today` | 获取今日日志 | - |
| GET | `/journals?from=&to=&limit=50` | 获取日期范围日志 | - |
| GET | `/journals/random?exclude_today=true` | 获取随机日志 | - |
| GET | `/journals/random-with-msg` | 获取随机日志+温暖消息 | - |

### 安全设置 (Safety)

#### 紧急联系人
| 方法 | 端点 | 功能 |
|------|------|------|
| GET | `/users/me/emergency-contact` | 获取紧急联系人 |
| PUT | `/users/me/emergency-contact` | 新增/更新紧急联系人 |

请求体:
```json
{
  "name": "联系人名字",
  "email": "contact@example.com",
  "relationship": "关系描述 (可选)"
}
```

#### 签到提醒
| 方法 | 端点 | 功能 |
|------|------|------|
| GET | `/users/me/checkin-reminder` | 获取签到提醒设置 |
| PUT | `/users/me/checkin-reminder` | 更新签到提醒 |

请求体:
```json
{
  "enabled": true,
  "time_local": "09:00",
  "frequency_type": "daily",
  "interval_days": null
}
```

或:
```json
{
  "enabled": true,
  "time_local": "09:00",
  "frequency_type": "every_n_days",
  "interval_days": 3
}
```

#### 缺失签到规则
| 方法 | 端点 | 功能 |
|------|------|------|
| GET | `/users/me/miss-checkin-rule` | 获取缺失签到规则 |
| PUT | `/users/me/miss-checkin-rule` | 更新缺失签到规则 |

请求体:
```json
{
  "threshold_days": 3,
  "message_template": "Hi, {contact_name}, this is Lumenary..."
}
```

#### 暂停签到
| 方法 | 端点 | 功能 |
|------|------|------|
| GET | `/users/me/pause-checkin` | 获取暂停状态 |
| POST | `/users/me/pause-checkin` | 设置暂停状态 |

请求体:
```json
{
  "paused": true
}
```

---

## 请求头

| 头部 | 说明 | 示例 |
|------|------|------|
| X-User-Timezone | 用户时区 (IANA 格式) | `America/New_York` |

**时区优先级**: 请求头 > 数据库保存 > UTC 默认

---

## 响应格式

### 成功响应
```json
{
  "data": { ... },
  "message": "OK"
}
```

### 错误状态码
| 状态码 | 说明 |
|--------|------|
| 201 | 资源创建成功 |
| 400 | 请求验证失败 |
| 403 | 暂停状态禁止操作 |
| 404 | 资源不存在 |
| 409 | 冲突 (已存在相同记录) |
| 422 | 验证错误 |
| 500 | 服务器错误 |

---

## AI 温暖消息

使用 Google Gemini API 为日志生成个性化鼓励消息。

### 配置
```
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-3-flash-preview
```

### 输出格式
每个日志生成 3 条备选温暖消息，每条包含:
- `warm_message`: 消息内容 (≤200字)
- `tags`: 标签列表

### 消息标签 (WarmMessageTags)
- EMPATHY: 同理心
- ENCOURAGEMENT: 鼓励
- CALM: 平静
- PROUD: 自豪
- GROUNDING: 接地气
- SUPPORT: 支持
- HOPE: 希望

---

## 后台任务

### 缺失签到扫描
- **频率**: 每 5 分钟执行一次
- **逻辑**:
  1. 扫描所有配置了缺失签到规则的用户
  2. 跳过暂停状态的用户
  3. 计算距离最后签到的天数
  4. 如果超过阈值天数，发送邮件给紧急联系人
  5. 记录警报日志，确保同一缺失窗口只发送一次

---

## 目录结构

```
server/
├── main.py                 # FastAPI 应用入口
├── deps.py                 # 依赖注入
├── core/
│   ├── config.py          # 应用配置
│   └── security.py        # JWT 和密码处理
├── db/
│   ├── base.py            # ORM 基类
│   └── session.py         # 数据库会话
├── models/                 # 数据模型
├── schemas/                # Pydantic 验证
├── routers/                # API 路由
├── services/               # 业务逻辑
├── ai/
│   ├── gemini_client.py   # Gemini 客户端
│   └── prompt.py          # AI 提示词
├── jobs/
│   └── miss_checkin_scheduler.py  # 后台调度
├── utils/                  # 工具函数
└── alembic/                # 数据库迁移
```

---

## 环境变量

```bash
# 应用
PROJECT_NAME=Life Tracker API
DEBUG=true
PORT=8000

# 数据库
DATABASE_URL=postgresql://postgres:123456@db:5432/lumenary

# 安全
SECRET_KEY=your-secret-key
TOKEN_PEPPER=your-token-pepper

# AI
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-3-flash-preview

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]

# 邮件 (Docker 环境)
SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_FROM=no-reply@lumenary.local
```

---

## Demo 用户

项目内置演示用户用于测试:
- **User ID**: `00000000-0000-0000-0000-000000000001`
- **Email**: `demo@test.com`

应用启动时自动创建 (如果不存在)。
