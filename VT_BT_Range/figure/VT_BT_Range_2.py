import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# 数据
data = [
    [16, 21, 26, 31, 37],
    [27, 30, 35, 41, 45],
    [32, 39, 43, 50, 53],
    [35, 40, 45, 50, 57],
    [1246, 1256, 1268, 1276, 1285]
]

data2 = [
    [1, 2, 3, 4, 5],
    [1, 2,3, 4, 5],
    [1, 2, 3, 4, 5],
    [1, 2,3, 4, 5],
    [1, 2,3, 4, 5]
]

# 创建子图
fig, axes = plt.subplots(1, 5, figsize=(20, 3))
# 使用颜色映射
cmap = plt.cm.Blues  # 使用蓝色渐变
norm = plt.Normalize(vmin=0.1, vmax=1.5)  # 根据所有数据标准化颜色
x_lable = ['39-bus', '118-bus', '300-bus', '500-bus', '2383-bus']
# 绘制每个子图
for i, ax in enumerate(axes):
    x = data2[i]  # 横坐标
    y = data[i]  # 纵坐标

    # 将数据按矩形大小排序，从大到小排序
    sorted_data = sorted(zip(x, y), key=lambda xy: xy[0] * xy[1], reverse=True)

    # 绘制每个数据点对应的矩形阴影，先绘制大的矩形，最后绘制小的矩形
    for xi, yi in sorted_data:
        color = cmap(norm(yi/max(y)))  # 根据 y 值映射颜色，数值越大颜色越深
        rect = patches.Rectangle((0, 0), xi, yi, linewidth=1, edgecolor='black', facecolor=color, alpha=1, linestyle= '-.')
        ax.add_patch(rect)

    # 绘制数据点
    ax.scatter(x, y, color='#1942A4', zorder=10)  # 数据点在最上方

    # 设置横坐标刻度为数据点的值
    ax.set_xticks(x)
    ax.set_xticklabels([f'{xi}%' for xi in range(0, 101, 25)])  # 转换成百分比格式

    # 设置纵坐标的刻度
    max_val_y = max(y)
    # 设置 y 轴刻度为数据点的 y 值
    ax.set_yticks(y)

    # 设置标题和坐标轴标签
    ax.set_title(x_lable[i])
    ax.set_xlabel("Load Variation Ranges")

    # 设置坐标轴范围确保方形显示完整
    ax.set_xlim(0, max(x) * 1.1)
    ax.set_ylim(0, max(y) * 1.1)

axes[0].set_ylim(10, 65)
axes[1].set_ylim(10, 65)
axes[2].set_ylim(10, 65)
axes[3].set_ylim(10, 65)
axes[4].set_ylim(1200, 1290)

axes[0].set_ylabel('The Number of Kept Line Limits')
# 调整子图之间的间距
plt.tight_layout()
plt.show()
